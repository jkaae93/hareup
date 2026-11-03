import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../records/domain/record.dart';
import '../domain/analysis.dart';

enum AnalysisStage {
  ready,
  analyzing,
  unavailable,
  review,
  saving,
  saved,
  failed,
}

class AnalysisState {
  const AnalysisState({
    required this.stage,
    this.request,
    this.outcome,
    this.analyzedAt,
    this.failure,
    this.modelResponse,
  });
  final AnalysisStage stage;
  final AnalysisRequest? request;
  final AnalysisOutcome? outcome;
  final DateTime? analyzedAt;
  final AppFailure? failure;
  final String? modelResponse;
}

class AnalysisCubit extends BaseCubit<AnalysisState> {
  AnalysisCubit({
    required this.service,
    required this.records,
    this.validation = const AnalysisValidation(),
  }) : super(const AnalysisState(stage: AnalysisStage.ready));
  final AnalysisService service;
  final RecordsRepository records;
  final AnalysisValidation validation;
  int _generation = 0;

  Future<void> analyze(AnalysisRequest request) async {
    if (isClosed ||
        state.stage == AnalysisStage.analyzing ||
        state.stage == AnalysisStage.saving) {
      return;
    }
    if (request.photo.isEmpty ||
        request.baseline.photo.isEmpty ||
        request.baseline.version < 1 ||
        request.groupId.isEmpty ||
        request.targetId.isEmpty ||
        request.id.isEmpty) {
      emit(
        const AnalysisState(
          stage: AnalysisStage.failed,
          failure: RequestFailure('기준 사진과 비교할 사진을 확인해 주세요.'),
        ),
      );
      return;
    }
    final generation = ++_generation;
    emit(AnalysisState(stage: AnalysisStage.analyzing, request: request));
    try {
      final result = await service.analyze(request);
      if (isClosed || generation != _generation) return;
      switch (result) {
        case Failure<AnalysisOutcome>(:final failure):
          emit(
            AnalysisState(
              stage: AnalysisStage.failed,
              request: request,
              failure: failure,
            ),
          );
        case Success<AnalysisOutcome>(:final value):
          final outcome = gateAnalysis(request, value, validation);
          emit(
            AnalysisState(
              stage: outcome is AnalysisUnavailable
                  ? AnalysisStage.unavailable
                  : AnalysisStage.review,
              request: request,
              outcome: outcome,
              modelResponse: value.modelResponse,
              analyzedAt: DateTime.now().toUtc(),
            ),
          );
      }
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(
          AnalysisState(
            stage: AnalysisStage.failed,
            request: request,
            failure: mapFailure(error),
          ),
        );
      }
    }
  }

  Future<void> save({
    int? urineCount,
    int? stoolCount,
    String? selectedCatId,
    String notes = '',
  }) async {
    final previous = state;
    if (isClosed || previous.stage != AnalysisStage.review) return;
    final outcome = previous.outcome!;
    if ((urineCount != null && urineCount < 0) ||
        (stoolCount != null && stoolCount < 0) ||
        notes.length > 500 ||
        (selectedCatId != null &&
            !previous.request!.eligibleCats.any(
              (cat) => cat.id == selectedCatId,
            )) ||
        (outcome is! LitterOutcome &&
            (urineCount != null ||
                stoolCount != null ||
                selectedCatId != null))) {
      emit(
        AnalysisState(
          stage: AnalysisStage.review,
          request: previous.request,
          outcome: outcome,
          analyzedAt: previous.analyzedAt,
          failure: const RequestFailure('수정한 횟수를 확인해 주세요.'),
        ),
      );
      return;
    }
    emit(
      AnalysisState(
        stage: AnalysisStage.saving,
        request: previous.request,
        outcome: outcome,
        analyzedAt: previous.analyzedAt,
      ),
    );
    final record = ObservationRecord(
      request: previous.request!,
      outcome: outcome,
      analyzedAt: previous.analyzedAt!,
      correctedUrineCount: urineCount,
      correctedStoolCount: stoolCount,
      selectedCatId: selectedCatId,
      notes: notes.trim(),
    );
    try {
      final result = await records.save(record);
      if (isClosed) return;
      switch (result) {
        case Success<void>():
          emit(
            AnalysisState(
              stage: AnalysisStage.saved,
              request: previous.request,
              outcome: outcome,
              analyzedAt: previous.analyzedAt,
            ),
          );
        case Failure<void>(:final failure):
          emit(
            AnalysisState(
              stage: AnalysisStage.review,
              request: previous.request,
              outcome: outcome,
              analyzedAt: previous.analyzedAt,
              failure: failure,
            ),
          );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          AnalysisState(
            stage: AnalysisStage.review,
            request: previous.request,
            outcome: outcome,
            analyzedAt: previous.analyzedAt,
            failure: mapFailure(error),
          ),
        );
      }
    }
  }
}
