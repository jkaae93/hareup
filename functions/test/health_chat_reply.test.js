const test = require('node:test');
const assert = require('node:assert/strict');
const { MIN_REPLY_LENGTH, MAX_REPLY_LENGTH, replyLength, limitHealthReply } = require('../health_chat_reply');

test('accepts complete responses between 300 and 500 characters', async () => {
  for (const size of [300, 400, 500]) {
    const answer = '가'.repeat(size);
    assert.equal(await limitHealthReply(` ${answer} `, () => { throw Error('unexpected'); }, 'ko'), answer);
  }
});

test('rewrites short and long answers without cutting text', async () => {
  for (const original of ['가'.repeat(299), '가'.repeat(501)]) {
    let received;
    const result = await limitHealthReply(original, async (value) => { received = value; return '나'.repeat(350); }, 'ko');
    assert.equal(received, original);
    assert.equal(result, '나'.repeat(350));
  }
});

test('fallbacks stay in range, include urgent care guidance and handle emoji as characters', async () => {
  assert.equal(replyLength('🐈‍⬛'.repeat(300)), 300);
  for (const locale of ['ko', 'en']) {
    for (const rewrite of [async () => '가'.repeat(501), async () => { throw Error('offline'); }]) {
      const answer = await limitHealthReply('short', rewrite, locale);
      assert.ok(replyLength(answer) >= MIN_REPLY_LENGTH && replyLength(answer) <= MAX_REPLY_LENGTH);
      assert.match(answer, locale === 'ko' ? /응급 동물병원/ : /emergency veterinary care/);
    }
  }
});
