import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';

import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/family/data/unavailable_family_repository.dart';
import '../features/family/domain/family.dart';
import '../features/family/presentation/family_access_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/litter_box/data/firestore_litter_box_repository.dart';
import '../features/litter_box/data/memory_litter_box_repository.dart';
import '../features/litter_box/presentation/litter_box_cubit.dart';
import '../features/pet/data/firestore_pet_repository.dart';
import '../features/pet/data/memory_pet_repository.dart';
import '../features/pet/domain/pet.dart';
import '../features/pet/presentation/pet_cubit.dart';
import '../features/photo_analysis/data/firebase_meta_analysis_service.dart';
import '../features/photo_analysis/data/unavailable_analysis_service.dart';
import '../features/photo_analysis/domain/analysis.dart';
import '../features/records/data/firestore_records_repository.dart';
import '../features/records/data/memory_records_repository.dart';
import '../features/records/domain/record.dart';
import '../features/water_bowl/data/firestore_water_bowl_repository.dart';
import '../features/water_bowl/data/memory_water_bowl_repository.dart';
import '../features/water_bowl/presentation/water_bowl_cubit.dart';

class HareupApp extends StatelessWidget {
  const HareupApp({
    super.key,
    this.repository,
    this.authRepository,
    this.familyRepository,
    this.firestore,
    this.storage,
    this.functions,
    this.analysisRuntime,
  });

  /// Optional repository overrides keep previews and isolated UI harnesses simple.
  final PetRepository? repository;
  final AuthRepository? authRepository;
  final FamilyRepository? familyRepository;
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;
  final FirebaseFunctions? functions;
  final AnalysisRuntime? analysisRuntime;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        AuthCubit(authRepository ?? const _UnavailableAuth())..start(),
    child: MaterialApp(
      title: '하릅',
      theme: HareupTheme.light,
      home: AuthGate(
        signedInBuilder: (context, _) => familyRepository == null
            ? _GroupHome(
                groupId: analysisRuntime?.groupId ?? 'local-development',
                repository: repository,
                familyRepository: const UnavailableFamilyRepository(),
                firestore: firestore,
                storage: storage,
                functions: functions,
                analysisRuntime: analysisRuntime,
              )
            : _FamilySelection(
                familyRepository: familyRepository!,
                repository: repository,
                firestore: firestore,
                storage: storage,
                functions: functions,
              ),
      ),
    ),
  );
}

class _FamilySelection extends StatefulWidget {
  const _FamilySelection({
    required this.familyRepository,
    required this.repository,
    required this.firestore,
    required this.storage,
    required this.functions,
  });

  final FamilyRepository familyRepository;
  final PetRepository? repository;
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;
  final FirebaseFunctions? functions;

  @override
  State<_FamilySelection> createState() => _FamilySelectionState();
}

class _FamilySelectionState extends State<_FamilySelection> {
  String? _groupId;

  @override
  Widget build(BuildContext context) {
    final groupId = _groupId;
    if (groupId == null) {
      return FamilyAccessPage(
        repository: widget.familyRepository,
        onFamilySelected: (id) => setState(() => _groupId = id),
      );
    }
    return _GroupHome(
      key: ValueKey(groupId),
      groupId: groupId,
      repository: widget.repository,
      familyRepository: widget.familyRepository,
      firestore: widget.firestore,
      storage: widget.storage,
      functions: widget.functions,
      onChangeFamily: () => setState(() => _groupId = null),
    );
  }
}

class _GroupHome extends StatelessWidget {
  const _GroupHome({
    super.key,
    required this.groupId,
    required this.repository,
    required this.familyRepository,
    required this.firestore,
    required this.storage,
    required this.functions,
    this.analysisRuntime,
    this.onChangeFamily,
  });

  final String groupId;
  final PetRepository? repository;
  final FamilyRepository familyRepository;
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;
  final FirebaseFunctions? functions;
  final AnalysisRuntime? analysisRuntime;
  final VoidCallback? onChangeFamily;

  @override
  Widget build(BuildContext context) {
    final useFirebase = firestore != null && storage != null;
    final resolvedAnalysisRuntime =
        analysisRuntime ??
        AnalysisRuntime(
          service: functions == null
              ? const UnavailableAnalysisService()
              : FirebaseMetaAnalysisService(functions: functions!),
          groupId: groupId,
          // Keep unvalidated analysis hidden in release builds, but allow
          // real-device integration testing in debug builds.
          validation: kDebugMode
              ? const AnalysisValidation(waterPercent: true, litterCounts: true)
              : const AnalysisValidation(),
        );
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FamilyRepository>.value(value: familyRepository),
        RepositoryProvider<RecordsRepository>(
          create: (_) => useFirebase
              ? FirestoreRecordsRepository(
                  firestore: firestore!,
                  storage: storage!,
                )
              : MemoryRecordsRepository(),
        ),
        RepositoryProvider<AnalysisRuntime>.value(
          value: resolvedAnalysisRuntime,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PetCubit>(
            create: (_) => PetCubit(
              repository ??
                  (useFirebase
                      ? FirestorePetRepository(
                          firestore: firestore!,
                          storage: storage!,
                          groupId: groupId,
                        )
                      : MemoryPetRepository()),
            )..load(),
          ),
          BlocProvider<WaterBowlCubit>(
            create: (_) => WaterBowlCubit(
              useFirebase
                  ? FirestoreWaterBowlRepository(
                      firestore: firestore!,
                      storage: storage!,
                      groupId: groupId,
                    )
                  : MemoryWaterBowlRepository(),
            )..load(),
          ),
          BlocProvider<LitterBoxCubit>(
            create: (_) => LitterBoxCubit(
              useFirebase
                  ? FirestoreLitterBoxRepository(
                      firestore: firestore!,
                      storage: storage!,
                      groupId: groupId,
                    )
                  : MemoryLitterBoxRepository(),
            )..load(),
          ),
        ],
        child: HomePage(onChangeFamily: onChangeFamily),
      ),
    );
  }
}

class _UnavailableAuth implements AuthRepository {
  const _UnavailableAuth();

  @override
  List<AuthProviderOption> get providers => const [];

  @override
  Stream<AuthSession?> observeSession() => Stream.value(null);

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const Failure(RequestFailure('Firebase 인증 설정을 사용할 수 없습니다.'));

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async => const Failure(RequestFailure('Firebase 인증 설정을 사용할 수 없습니다.'));

  @override
  Future<Result<void>> signInWithProvider(String providerId) async =>
      const Failure(RequestFailure('Firebase 인증 설정을 사용할 수 없습니다.'));

  @override
  Future<Result<void>> signOut() async => const Success(null);
}
