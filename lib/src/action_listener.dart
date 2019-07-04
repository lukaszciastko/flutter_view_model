part of view_model;

/// A widget the executes the [onValue] callback when the value of an [Action] changes.
///
class ActionListener<In, R> extends StatefulWidget {
  const ActionListener({
    Key key,
    this.action,
    this.onValue,
    @required this.child,
  }) : super(key: key);

  final Action<In, R> action;
  final ValueChanged<Result<R>> onValue;
  final Widget child;

  @override
  _ActionListenerState<In, R> createState() => _ActionListenerState<In, R>();
}

class _ActionListenerState<In, R> extends State<ActionListener<In, R>> {
  @override
  void initState() {
    super.initState();
    _addOnValueListener(widget);
  }

  @override
  void didUpdateWidget(ActionListener<In, R> oldWidget) {
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

  void _addOnValueListener(ActionListener<In, R> widget) {
    if (widget.action != null && widget.onValue != null) {
      widget.action.addListener(_onValue);
    }
  }

  void _removeOnValueListener(ActionListener<In, R> widget) {
    if (widget.action != null && widget.onValue != null) {
      widget.action.removeListener(_onValue);
    }
  }
}
