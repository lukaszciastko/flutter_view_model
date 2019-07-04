part of view_model;

/// A signature for the builder callback used by [ActionBuilder].
///
typedef ActionWidgetBuilder<T> = Widget Function(BuildContext context, Result<T> result);

/// A widget that builds itself when the value of an [Action] changes.
///
class ActionBuilder<In, R> extends StatelessWidget {
  const ActionBuilder({
    Key key,
    @required this.action,
    this.onValue,
    @required this.builder,
  }) : super(key: key);

  final Action<In, R> action;
  final ValueChanged<Result<R>> onValue;
  final ActionWidgetBuilder<R> builder;

  @override
  Widget build(BuildContext context) {
    return ActionListener<In, R>(
      action: action,
      onValue: onValue,
      child: ValueListenableBuilder<Result<R>>(
        valueListenable: action,
        builder: (BuildContext context, Result<R> value, _) {
          return builder(context, value);
        },
      ),
    );
  }
}
