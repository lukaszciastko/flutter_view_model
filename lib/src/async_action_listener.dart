part of view_model;

/// A widget the executes the [onValue] callback when the value of an [AsyncAction] changes.
///
class AsyncActionListener<In, R> extends StatefulWidget {
  const AsyncActionListener({
    Key key,
    this.action,
    this.onValue,
    @required this.child,
  }) : super(key: key);

  final AsyncAction<In, R> action;
  final ValueChanged<Result<R>> onValue;
  final Widget child;

  @override
  _AsyncActionListenerState<In, R> createState() => _AsyncActionListenerState<In, R>();
}

class _AsyncActionListenerState<In, R> extends State<AsyncActionListener<In, R>> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onValue() {
    widget.onValue(widget.action.value);
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
