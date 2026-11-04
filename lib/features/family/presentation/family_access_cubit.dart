import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';

import '../domain/family.dart';

class FamilyAccessState {
  const FamilyAccessState({
    this.families = const [],
    this.pendingGroupId,
    this.isLoading = false,
    this.failure,
  });

  final List<FamilyGroup> families;
  final String? pendingGroupId;
  final bool isLoading;

  /// Resolved to display text at the presentation boundary.
  final AppFailure? failure;
}

class FamilyAccessCubit extends Cubit<FamilyAccessState> {
  FamilyAccessCubit(this.repository) : super(const FamilyAccessState());

  final FamilyRepository repository;

  Future<void> load() async {
    emit(
      FamilyAccessState(
        families: state.families,
        pendingGroupId: state.pendingGroupId,
        isLoading: true,
      ),
    );
    final result = await repository.listMyFamilies();
    if (isClosed) return;
    if (result case Success<List<FamilyGroup>>(:final value)) {
      emit(
        FamilyAccessState(
          families: value,
          pendingGroupId: state.pendingGroupId,
        ),
      );
      final pendingId = state.pendingGroupId;
      if (pendingId != null) await refreshJoinStatus(pendingId);
    } else if (result case Failure<List<FamilyGroup>>(:final failure)) {
      emit(
        FamilyAccessState(
          families: state.families,
          pendingGroupId: state.pendingGroupId,
          failure: failure,
        ),
      );
    }
  }

  Future<String?> createFamily(String name) async {
    emit(FamilyAccessState(families: state.families, isLoading: true));
    final result = await repository.createFamily(name);
    if (isClosed) return null;
    if (result case Success<String>(:final value)) {
      // The create response already identifies the approved family. Avoid a
      // second network round trip here: a list refresh failure must not show
      // an error while the user is being routed into the family they created.
      emit(
        FamilyAccessState(
          families: [
            ...state.families.where((family) => family.id != value),
            FamilyGroup(id: value, name: name.trim()),
          ],
        ),
      );
      return value;
    } else if (result case Failure<String>(:final failure)) {
      emit(FamilyAccessState(families: state.families, failure: failure));
    }
    return null;
  }

  Future<String?> requestToJoin(String code) async {
    emit(FamilyAccessState(families: state.families, isLoading: true));
    final result = await repository.requestToJoin(code);
    if (isClosed) return null;
    if (result case Success<String>(:final value)) {
      emit(FamilyAccessState(families: state.families, pendingGroupId: value));
      return value;
    } else if (result case Failure<String>(:final failure)) {
      emit(FamilyAccessState(families: state.families, failure: failure));
    }
    return null;
  }

  Future<void> refreshJoinStatus(String groupId) async {
    final result = await repository.getJoinStatus(groupId);
    if (isClosed) return;
    if (result case Success<String>(value: 'approved')) {
      emit(FamilyAccessState(families: state.families, pendingGroupId: null));
      await load();
    } else if (result case Failure<String>(:final failure)) {
      emit(
        FamilyAccessState(
          families: state.families,
          pendingGroupId: groupId,
          failure: failure,
        ),
      );
    }
  }
}
