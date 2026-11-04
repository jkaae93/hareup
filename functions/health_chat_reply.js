const MIN_REPLY_LENGTH = 300;
const MAX_REPLY_LENGTH = 500;
const segmenter = new Intl.Segmenter('en', { granularity: 'grapheme' });
function replyLength(text) {
  return Array.from(segmenter.segment(text)).length;
}
function isValidReply(value) {
  if (typeof value !== 'string') return false;
  const length = replyLength(value.trim());
  return length >= MIN_REPLY_LENGTH && length <= MAX_REPLY_LENGTH;
}
const fallback = {
  ko: '사진이나 설명만으로는 원인을 확정할 수 없으므로, 증상의 시작 시점과 지속 시간, 평소와 달라진 식욕·활동량·음수 및 배변 상태를 기록해 수의사에게 알려주세요. 호흡이 어렵거나 쓰러짐, 반복되는 경련, 심한 출혈, 독성 물질 섭취가 의심되거나 소변을 보지 못한다면 지체하지 말고 응급 동물병원에 연락하세요. 증상이 심하지 않더라도 지속되거나 악화된다면 빠르게 진료를 예약하는 것이 좋습니다. 음식이나 약을 임의로 투여하지 말고, 증상과 관련된 사진이나 관찰 기록을 함께 전달해 주세요. 이 안내는 일반 정보이며 진찰이나 진단을 대신하지 않습니다.',
  en: 'A photo or message cannot establish the cause. Note when signs began and any changes in appetite, energy, drinking, urination or stool, then share them with your veterinarian. Seek emergency veterinary care now for breathing difficulty, collapse, seizures, serious bleeding, suspected poisoning or inability to urinate. Arrange prompt care if signs persist or worsen. Do not give medication without veterinary advice. This information does not replace an examination or diagnosis.',
};

// Rewriting preserves complete guidance. If it fails, return a complete safety
// message rather than cutting a sentence or inventing details to fill space.
async function limitHealthReply(reply, rewrite, languageCode) {
  const original = reply.trim();
  if (isValidReply(original)) return original;
  try {
    const revised = await rewrite(original);
    if (isValidReply(revised)) return revised.trim();
  } catch (_) {
    // The fallback is complete even if the provider cannot rewrite.
  }
  return fallback[languageCode] || fallback.ko;
}
module.exports = { MIN_REPLY_LENGTH, MAX_REPLY_LENGTH, replyLength, isValidReply, limitHealthReply };
