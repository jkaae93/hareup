const RECORD_SAMPLE_LIMIT = 100;
const BOWL_SAMPLE_LIMIT = 50;
const PER_PET_LIMIT = 5;

function timestamp(value) {
  if (!value) return null;
  const date = typeof value.toDate === 'function' ? value.toDate() : value instanceof Date ? value : null;
  return date && Number.isFinite(date.getTime()) ? date.toISOString() : null;
}
function finite(value, min = 0, max = Number.MAX_SAFE_INTEGER) {
  return typeof value === 'number' && Number.isFinite(value) && value >= min && value <= max ? value : null;
}
function count(value) {
  return Number.isInteger(value) && value >= 0 && value <= 1000 ? value : null;
}
function text(value, max = 100) {
  return typeof value === 'string' ? value.slice(0, max) : null;
}

// Every query is rooted in the already-authorized family. Records are a bounded
// recent sample and water belongs to a bowl, never to an individual pet.
async function loadMentionedPetContext(group, petSnapshots) {
  if (!petSnapshots.length) return [];
  const petIds = petSnapshots.map((pet) => pet.id);
  const [recordSnapshot, bowlSnapshot] = await Promise.all([
    group.collection('records').orderBy('analyzedAt', 'desc').limit(RECORD_SAMPLE_LIMIT).get(),
    group.collection('waterBowls').where('petIds', 'array-contains-any', petIds).limit(BOWL_SAMPLE_LIMIT).get(),
  ]);
  const records = recordSnapshot.docs.map((doc) => doc.data());
  const bowls = bowlSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
  return petSnapshots.map((pet) => {
    const data = pet.data();
    const waterBowls = bowls.filter((bowl) => Array.isArray(bowl.petIds) && bowl.petIds.includes(pet.id)).slice(0, PER_PET_LIMIT).map((bowl) => {
      const current = bowl.latestWaterLevel || {};
      const waterObservations = records.filter((record) => record.kind === 'water' && record.targetId === bowl.id && record.outcome?.type === 'water').slice(0, PER_PET_LIMIT).map((record) => ({
        observedAt: timestamp(record.analyzedAt),
        // These are historical bowl estimates, never an individual's intake.
        estimatedDecreasePercent: finite(record.outcome.percent, 0, 100),
        estimatedDecreaseMl: finite(record.outcome.volumeMl),
        validation: 'unverified_bowl_estimate_not_individual_intake',
      }));
      return {
        name: text(bowl.name),
        shared: bowl.petIds.length > 1,
        latestLevel: finite(current.fillPercent, 0, 100) == null ? null : {
          estimatedFillPercent: finite(current.fillPercent, 0, 100),
          observedAt: timestamp(current.observedAt),
          validation: 'unverified_estimate_not_individual_intake',
        },
        recentBowlObservations: waterObservations,
      };
    });
    const litterObservations = records.filter((record) => record.kind === 'litter' && record.selectedCatId === pet.id && record.outcome?.type === 'litter').slice(0, PER_PET_LIMIT).map((record) => {
      const outcome = record.outcome;
      const quantity = finite(outcome.observedQuantity);
      const unit = text(outcome.quantityUnit, 20);
      return {
        boxName: text(record.targetName),
        observedAt: timestamp(record.analyzedAt),
        urineCount: count(record.correctedUrineCount ?? outcome.urineCount),
        stoolCount: count(record.correctedStoolCount ?? outcome.stoolCount),
        estimatedQuantity: quantity != null && unit ? { value: quantity, unit } : null,
        validation: 'unverified_photo_estimate_user_assigned_pet',
        uncertain: outcome.uncertain === true,
      };
    });
    return {
      id: pet.id,
      name: text(data.name),
      species: ['cat', 'dog'].includes(data.species) ? data.species : null,
      ageMonths: Number.isInteger(data.ageMonths) ? finite(data.ageMonths, 0, 1200) : null,
      weightKg: finite(data.weightKg, 0.001, 1000),
      sex: ['female', 'male', 'unknown'].includes(data.sex) ? data.sex : null,
      individualWaterIntake: null,
      waterIntakeNote: 'Individual intake is not measured; bowl estimates are not individual intake.',
      waterBowls,
      litterObservations,
      recordsScope: 'Up to 5 relevant observations from the latest 100 family records; absence does not imply zero.',
    };
  });
}
module.exports = { loadMentionedPetContext, RECORD_SAMPLE_LIMIT, BOWL_SAMPLE_LIMIT, PER_PET_LIMIT };
