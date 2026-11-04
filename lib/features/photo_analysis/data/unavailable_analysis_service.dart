import 'package:hareup_core/core.dart';
import '../domain/analysis.dart';

/// No model or validation is configured in the development app.
class UnavailableAnalysisService implements AnalysisService {
  const UnavailableAnalysisService();
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(
        AnalysisUnavailable(
          '사진 분석 서비스가 아직 준비되지 않았습니다.',
          reasonKey: FailureMessageKeys.analysisServiceUnavailable,
        ),
      );
}
