part of view_model;

class Result<T> {
  Result._internal(this.value, this.error);

  final T value;
  final dynamic error;

  bool get isAwaiting {
    return this is AwaitingResult<T>;
  }

  bool get isAwaitingInitial {
    return isAwaiting && !isAwaitingInProgress;
  }

  bool get isAwaitingInProgress {
    return this is AwaitingResultInProgress<T>;
  }

  bool get hasValue {
    return this is ValueResult<T>;
  }

  bool get hasError {
    return this is ErrorResult<T>;
  }
}

class AwaitingResult<T> extends Result<T> {
  AwaitingResult() : super._internal(null, null);
}

class AwaitingResultInProgress<T> extends AwaitingResult<T> {
  AwaitingResultInProgress() : super();
}

class ValueResult<T> extends Result<T> {
  ValueResult(T value) : super._internal(value, null);
}

class ErrorResult<T> extends Result<T> {
  ErrorResult(dynamic error) : super._internal(null, error);
}

typedef AsyncActionMapper<In, R> = Future<R> Function(In input);

/// A utility class that holds the value of an input.
///
class _InputSnapshot<T> {
  _InputSnapshot(this.value);
  final T value;
}

class AsyncAction<In, R> extends ChangeNotifier implements LifecycleListener, ValueListenable<Result<R>> {
  AsyncAction(
    this.mapper, {
    LifecycleProvider lifecycle,
    this.initialInput,
  }) {
    if (lifecycle != null) {
      lifecycle.addLifecycleListener(this);
    } else {
      init();
    }
  }

  final AsyncActionMapper<In, R> mapper;
  final In initialInput;

  In get input => _inputSnapshot.value;
  _InputSnapshot<In> _inputSnapshot;

  Result<R> get result => _result;
  Result<R> _result = AwaitingResult<R>();

  @override
  Result<R> get value => result;

  Stream<Result<R>> get stream => _initStreamControllerIfNull().stream;
  StreamController<Result<R>> _streamController;

  @override
  void onInit() {
    init();
  }

  void init() {
    if (initialInput != null && input == null) {
      perform(input: initialInput);
    }
  }

  @override
  void onDispose() {
    dispose();
  }

  @override
  dispose() {
    super.dispose();
    if (_streamController != null && !_streamController.isClosed) {
      _streamController?.close();
    }
  }

  Future<R> perform({In input, bool notifyAwaitingResult = true, bool notifyError = true}) async {
    final _InputSnapshot<In> inputSnapshot = _inputSnapshot = _InputSnapshot<In>(input);
    if (notifyAwaitingResult && !(_result is AwaitingResultInProgress<R>)) {
      _setResultAndNotifyListeners(AwaitingResultInProgress<R>());
    }
    try {
      final R result = await mapper(input);
      if (inputSnapshot == _inputSnapshot) {
        _setResultAndNotifyListeners(ValueResult<R>(result));
      }
      return result;
    } catch (e) {
      if (notifyError && inputSnapshot == _inputSnapshot) {
        _setResultAndNotifyListeners(ErrorResult<R>(e));
      }
      rethrow;
    }
  }

  Future<R> tryPerform({In input, bool notifyAwaitingResult = true, bool notifyError = true}) async {
    try {
      return await perform(
        input: input,
        notifyAwaitingResult: notifyAwaitingResult,
        notifyError: notifyError,
      );
    } catch (_) {
      return null;
    }
  }

  void _setResultAndNotifyListeners(Result<R> value) {
    if (_result != value) {
      _result = value;
      notifyListeners();
      if (_streamController != null) {
        _addValueToStreamController(value);
      }
    }
  }

  void _addValueToStreamController(Result<R> value) {
    if (value is AwaitingResult<R> || value is ValueResult<R>) {
      _streamController.add(value);
    } else if (value is ErrorResult<R>) {
      _streamController.addError(value);
    }
  }

  StreamController<Result<R>> _initStreamControllerIfNull() {
    if (_streamController == null) {
      _streamController = StreamController<Result<R>>.broadcast();
      _addValueToStreamController(value);
    }
    return _streamController;
  }
}
