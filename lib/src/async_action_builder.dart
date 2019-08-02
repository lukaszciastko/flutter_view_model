part of view_model;

/// A signature for the builder callback used by [AsyncActionBuilder].
///
typedef ActionWidgetBuilder<T> = Widget Function(BuildContext context, Result<T> result);

/// A widget that builds itself when the value of an [AsyncAction] changes.
///
class AsyncActionBuilder<In, R> extends StatelessWidget {
  const AsyncActionBuilder({
    Key key,
    @required this.action,
    this.initialValue,
    this.onValue,
    @required this.builder,
  }) : super(key: key);

  final AsyncAction<In, R> action;
  final Result<R> initialValue;
  final ValueChanged<Result<R>> onValue;
  final ActionWidgetBuilder<R> builder;

  @override
  Widget build(BuildContext context) {
    return AsyncActionListener<In, R>(
      action: action,
      initialValue: initialValue,
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
