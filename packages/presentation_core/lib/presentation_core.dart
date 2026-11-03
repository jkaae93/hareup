import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';

sealed class LoadState<T> {
  const LoadState();
}

final class Initial<T> extends LoadState<T> {
  const Initial();
}

final class Loading<T> extends LoadState<T> {
  const Loading();
}

final class Loaded<T> extends LoadState<T> {
  const Loaded(this.data);
  final T data;
}

final class Empty<T> extends LoadState<T> {
  const Empty();
}

final class Failed<T> extends LoadState<T> {
  const Failed(this.failure);
  final AppFailure failure;
}

/// Shared foundation for feature Cubits with any state shape.
abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);

  /// Override when a feature needs to translate additional error types.
  AppFailure mapFailure(Object error) =>
      error is AppFailure ? error : const UnexpectedFailure();

  /// Emits only while this Cubit is active, including after asynchronous work.
  void emitIfOpen(T state) {
    if (!isClosed) emit(state);
  }

  /// Runs an operation and delegates failure handling to the feature.
  /// The callbacks are skipped if the Cubit has closed while awaiting it.
  Future<void> runGuarded<R>(
    Future<R> Function() operation, {
    required void Function(R value) onSuccess,
    required void Function(AppFailure failure) onFailure,
  }) async {
    if (isClosed) return;
    late final R value;
    try {
      value = await operation();
    } catch (error) {
      if (!isClosed) onFailure(mapFailure(error));
      return;
    }
    if (!isClosed) onSuccess(value);
  }
}

abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(super.initialState);
  AppFailure mapFailure(Object error) =>
      error is AppFailure ? error : const UnexpectedFailure();
}

/// A Cubit for screens that load a single value asynchronously.
///
/// When requests overlap, only the most recently started request can update
/// state. Results arriving after the Cubit is closed are ignored.
abstract class LoadCubit<T> extends BaseCubit<LoadState<T>> {
  LoadCubit() : super(Initial<T>());

  int _request = 0;

  Future<void> loadValue(
    Future<T> Function() operation, {
    bool Function(T value)? isEmpty,
  }) async {
    final request = ++_request;
    if (isClosed) return;
    emit(Loading<T>());
    try {
      final value = await operation();
      if (isClosed || request != _request) return;
      emit(isEmpty?.call(value) == true ? Empty<T>() : Loaded<T>(value));
    } catch (error) {
      if (isClosed || request != _request) return;
      emit(Failed(mapFailure(error)));
    }
  }

  /// Loads a value from a repository that returns an explicit result.
  Future<void> loadResult(
    Future<Result<T>> Function() operation, {
    bool Function(T value)? isEmpty,
  }) async {
    final request = ++_request;
    if (isClosed) return;
    emit(Loading<T>());
    try {
      final result = await operation();
      if (isClosed || request != _request) return;
      switch (result) {
        case Success<T>(:final value):
          emit(isEmpty?.call(value) == true ? Empty<T>() : Loaded(value));
        case Failure<T>(:final failure):
          emit(Failed(failure));
      }
    } catch (error) {
      if (!isClosed && request == _request) emit(Failed(mapFailure(error)));
    }
  }
}

/// State of a single user action, independent of the screen's loading state.
sealed class CommandState<T> {
  const CommandState();
}

final class CommandIdle<T> extends CommandState<T> {
  const CommandIdle();
}

final class CommandRunning<T> extends CommandState<T> {
  const CommandRunning();
}

final class CommandSuccess<T> extends CommandState<T> {
  const CommandSuccess(this.value);
  final T value;
}

final class CommandFailure<T> extends CommandState<T> {
  const CommandFailure(this.failure);
  final AppFailure failure;
}

/// Tracks one action and prevents another execution while it is running.
abstract class BaseCommandCubit<T> extends BaseCubit<CommandState<T>> {
  BaseCommandCubit() : super(CommandIdle<T>());

  Future<void> executeOperation(Future<Result<T>> Function() operation) async {
    if (isClosed || state is CommandRunning<T>) return;
    emit(CommandRunning<T>());
    try {
      final result = await operation();
      if (isClosed) return;
      switch (result) {
        case Success<T>(:final value):
          emit(CommandSuccess(value));
        case Failure<T>(:final failure):
          emit(CommandFailure(failure));
      }
    } catch (error) {
      if (!isClosed) emit(CommandFailure(mapFailure(error)));
    }
  }

  /// Clears a completed result. A running operation cannot be reset.
  void reset() {
    if (!isClosed && state is! CommandRunning<T>) emit(CommandIdle<T>());
  }
}

/// A command without an argument.
final class Command0<T> extends BaseCommandCubit<T> {
  Command0(this._action);
  final Future<Result<T>> Function() _action;

  Future<void> execute() => executeOperation(_action);
}

/// A command accepting one argument; use a value object for multiple inputs.
final class Command1<T, A> extends BaseCommandCubit<T> {
  Command1(this._action);
  final Future<Result<T>> Function(A) _action;

  Future<void> execute(A argument) => executeOperation(() => _action(argument));
}
