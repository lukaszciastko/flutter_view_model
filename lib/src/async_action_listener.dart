part of view_model;

/// A widget the executes the [onValue] callback when the value of an [AsyncAction] changes.
///
class AsyncActionListener<In, R> extends StatefulWidget {
  const AsyncActionListener({
    Key key,
    this.action,
    this.initialValue,
    this.onValue,
    this.onDispose,
    @required this.child,
  }) : super(key: key);

  final AsyncAction<In, R> action;
  final Result<R> initialValue;
  final ValueChanged<Result<R>> onValue;
  final VoidCallback onDispose;
  final Widget child;

  @override
  _AsyncActionListenerState<In, R> createState() => _AsyncActionListenerState<In, R>();
}

class _AsyncActionListenerState<In, R> extends State<AsyncActionListener<In, R>> {
  bool _emittedInitialValue = false;

  @override
  void initState() {
    super.initState();
    _addOnValueListener(widget);
  }

  @override
  void didUpdateWidget(AsyncActionListener<In, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onValue != widget.onValue) {
      _removeOnValueListener(oldWidget);
      _addOnValueListener(widget);
    }
  }

  @override
  void dispose() {
    _removeOnValueListener(widget);
    if (widget.onDispose != null) {
      widget.onDispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onValue() {
    Result<R> value = widget.action.value;
    if (!_emittedInitialValue) {
      if (widget.initialValue != null) {
        value = widget.initialValue;
      }
      _emittedInitialValue = true;
    }
    widget.onValue(value);
  }

  void _addOnValueListener(AsyncActionListener<In, R> widget) {
    if (widget.action != null && widget.onValue != null) {
      widget.action.addListener(_onValue);
    }
  }

  void _removeOnValueListener(AsyncActionListener<In, R> widget) {
    if (widget.action != null && widget.onValue != null) {
      widget.action.removeListener(_onValue);
    }
  }
}
