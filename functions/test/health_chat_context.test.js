const test = require('node:test');
const assert = require('node:assert/strict');
const { loadMentionedPetContext } = require('../health_chat_context');

function snapshot(id, data) { return { id, data: () => data }; }
function groupFixture(records, bowls) {
  const calls = [];
  return { calls, collection(name) {
    calls.push(['collection', name]);
    if (name === 'records') return {
      orderBy(field, direction) { calls.push(['orderBy', field, direction]); return this; },
      limit(n) { calls.push(['limitRecords', n]); return this; },
      async get() { return { docs: records.map((record) => snapshot(record.id, record)) }; },
    };
    if (name === 'waterBowls') return {
      where(field, operation, values) { calls.push(['where', field, operation, values]); return this; },
      limit(n) { calls.push(['limitBowls', n]); return this; },
      async get() { return { docs: bowls.map((bowl) => snapshot(bowl.id, bowl)) }; },
    };
    throw new Error('Unexpected collection');
  } };
}

test('context includes profile, shared bowl estimates, only assigned litter, and explicit unknown intake', async () => {
  const date = new Date('2026-11-01T10:00:00Z');
  const records = [
    { id: 'a', kind: 'litter', targetName: 'box', selectedCatId: 'a', analyzedAt: date, correctedUrineCount: 3, outcome: { type: 'litter', urineCount: 2, stoolCount: 1, observedQuantity: null } },
    { id: 'b', kind: 'litter', selectedCatId: 'b', outcome: { type: 'litter', urineCount: 9, stoolCount: 9 } },
    { id: 'unknown', kind: 'litter', selectedCatId: null, outcome: { type: 'litter', urineCount: 99 } },
    { id: 'water', kind: 'water', targetId: 'shared', analyzedAt: date, outcome: { type: 'water', percent: 15, volumeMl: 30 } },
  ];
  const group = groupFixture(records, [
    { id: 'shared', name: 'bowl', petIds: ['a', 'b'], latestWaterLevel: { fillPercent: 65, observedAt: date } },
    { id: 'other', name: 'other', petIds: ['b'] },
  ]);
  const [pet] = await loadMentionedPetContext(group, [snapshot('a', { name: 'Nabi', species: 'cat', ageMonths: 24, weightKg: 4.2, sex: 'female' })]);
  assert.deepEqual([pet.name, pet.species, pet.ageMonths, pet.weightKg, pet.sex], ['Nabi', 'cat', 24, 4.2, 'female']);
  assert.equal(pet.individualWaterIntake, null);
  assert.equal(pet.waterBowls.length, 1);
  assert.equal(pet.waterBowls[0].shared, true);
  assert.equal(pet.waterBowls[0].latestLevel.estimatedFillPercent, 65);
  assert.match(pet.waterBowls[0].recentBowlObservations[0].validation, /not_individual_intake/);
  assert.equal(pet.litterObservations.length, 1);
  assert.equal(pet.litterObservations[0].urineCount, 3);
  assert.equal(pet.litterObservations[0].estimatedQuantity, null);
  assert.match(pet.litterObservations[0].validation, /unverified/);
  assert.ok(group.calls.some((call) => call[0] === 'limitRecords' && call[1] === 100));
  assert.deepEqual(group.calls.find((call) => call[0] === 'where'), ['where', 'petIds', 'array-contains-any', ['a']]);
});

test('handles missing data and avoids any data queries without mentions', async () => {
  const group = groupFixture([], []);
  assert.deepEqual(await loadMentionedPetContext(group, []), []);
  assert.deepEqual(group.calls, []);
  const [pet] = await loadMentionedPetContext(group, [snapshot('a', { name: 'Nabi', weightKg: NaN })]);
  assert.equal(pet.ageMonths, null);
  assert.equal(pet.weightKg, null);
  assert.equal(pet.individualWaterIntake, null);
  assert.deepEqual(pet.waterBowls, []);
  assert.deepEqual(pet.litterObservations, []);
});
