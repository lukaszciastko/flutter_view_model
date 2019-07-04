part of view_model;

/// A signature for the builder callback used by [ViewModelBuilder].
///
typedef ViewModelWidgetBuilder<T> = Widget Function(BuildContext context, T viewModel);

class ViewModelBuilder<T extends ViewModel> extends StatefulWidget {
  const ViewModelBuilder({
    Key key,
    this.viewModel,
    @required this.builder,
  }) : super(key: key);

  final ViewModelFactory<T> viewModel;
  final ViewModelWidgetBuilder<T> builder;

  @override
  _ViewModelBuilderState<T> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ViewModel> extends State<ViewModelBuilder<T>> {
  final GlobalKey<_ViewModelProviderState> _providerKey = GlobalKey<_ViewModelProviderState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      key: _providerKey,
      viewModel: widget.viewModel,
      child: Builder(
        builder: (BuildContext context) {
          return widget.builder(context, _getViewModel());
        },
      ),
    );
  }

  T _getViewModel() {
    return _providerKey.currentState.viewModel ?? ViewModelProvider.get<T>(context);
  }
}
