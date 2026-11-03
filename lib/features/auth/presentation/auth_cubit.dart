import 'dart:async';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/auth_repository.dart';

class AuthState {
  const AuthState({
    this.initialized = false,
    this.session,
    this.working = false,
    this.failure,
  });
  final bool initialized;
  final AuthSession? session;
  final bool working;
  final AppFailure? failure;
}

class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(this.repository) : super(const AuthState());
  final AuthRepository repository;
  StreamSubscription<AuthSession?>? _subscription;
  int _generation = 0;

  Future<void> start() async {
    final generation = ++_generation;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(const AuthState());
    try {
      _subscription = repository.observeSession().listen(
        (session) {
          if (!isClosed && generation == _generation) {
            emit(
              AuthState(
                initialized: true,
                session: session,
                working: state.working,
              ),
            );
          }
        },
        onError: (Object error) {
          if (!isClosed && generation == _generation) {
            // Invalidate in-flight operations and clear unverifiable sessions.
            _generation++;
            emit(
              const AuthState(initialized: true, failure: UnexpectedFailure()),
            );
          }
        },
      );
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(AuthState(initialized: true, failure: mapFailure(error)));
      }
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) => _execute(
    () => repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  Future<void> signIn({required String email, required String password}) =>
      _execute(() => repository.signIn(email: email, password: password));
  Future<void> signInWithProvider(String providerId) =>
      _execute(() => repository.signInWithProvider(providerId));
  Future<void> signOut() => _execute(repository.signOut, clearOnSuccess: true);

  Future<void> _execute(
    Future<Result<void>> Function() operation, {
    bool clearOnSuccess = false,
  }) async {
    if (isClosed || state.working || !state.initialized) return;
    final generation = _generation;
    emit(AuthState(initialized: true, session: state.session, working: true));
    try {
      final result = await operation();
      if (isClosed || generation != _generation) return;
      final failure = switch (result) {
        Failure<void>(:final failure) => failure,
        Success<void>() => null,
      };
      emit(
        AuthState(
          initialized: true,
          session: clearOnSuccess && failure == null ? null : state.session,
          failure: failure,
        ),
      );
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(
          AuthState(
            initialized: true,
            session: state.session,
            failure: mapFailure(error),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    await _subscription?.cancel();
    await super.close();
  }
}
