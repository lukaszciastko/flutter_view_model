part of view_model;

/// A factory method that returns an instance of a [ViewModel].
///
typedef ViewModelFactory<T extends ViewModel> = T Function();

/// A widget that builds an instance of a [ViewModel] using the specified [viewModel] factory method
/// and provides other widgets access to all instances of [ViewModel]s withing the widget tree.
///
class ViewModelProvider extends StatefulWidget {
  const ViewModelProvider({
    Key key,
    this.viewModel,
    @required this.child,
  }) : super(key: key);

  final ViewModelFactory<ViewModel> viewModel;
  final Widget child;

  @override
  _ViewModelProviderState createState() => _ViewModelProviderState();

  /// A static utility method that provides access to the root [ViewModelProvider]'s state.
  ///
  static _ViewModelProviderState of(BuildContext context) {
    return context.rootAncestorStateOfType(const TypeMatcher<_ViewModelProviderState>());
  }

  /// A static method that returns a [ViewModel] instance of the specified type if one exists
  /// in the widget tree. If no [ViewModel] of the specified type exists, the method throws a [StateError].
  ///
  static T get<T extends ViewModel>(BuildContext context) {
    return of(context).viewModels.lastWhere((ViewModel viewModel) => TypeMatcher<T>().check(viewModel));
  }
}

class _ViewModelProviderState extends State<ViewModelProvider> {
  ViewModel _viewModel;
  ViewModel get viewModel {
    return _viewModel ??= (widget.viewModel != null) ? widget.viewModel() : null;
  }

  List<ViewModel> _viewModels;
  List<ViewModel> get viewModels {
    return _viewModels ??= rootProvider._viewModels ??= <ViewModel>[];
  }

  _ViewModelProviderState get rootProvider {
    return ViewModelProvider.of(context) ?? this;
  }

  void publishEvent(dynamic event, [ViewModel source]) {
    for (ViewModel viewModel in viewModels) {
      if (viewModel != source) {
        viewModel.onEvent(event);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (viewModel != null) {
      viewModels.add(viewModel);
      viewModel._context = context;
      viewModel._publishEvent = (dynamic event) {
        publishEvent(event, viewModel);
      };
      viewModel.onInit();
      if (viewModel._lifecycleListeners != null) {
        for (LifecycleListener listener in viewModel._lifecycleListeners) {
          listener.onInit();
        }
      }
    }
  }

  @override
  void dispose() {
    if (viewModel != null) {
      viewModels.remove(viewModel);
      if (viewModel._lifecycleListeners != null) {
        for (LifecycleListener listener in viewModel._lifecycleListeners) {
          listener.onDispose();
        }
        viewModel._lifecycleListeners.clear();
      }
      viewModel.onDispose();
      viewModel._context = null;
      viewModel._publishEvent = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
