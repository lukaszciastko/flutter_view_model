part of view_model;

/// A base [ViewModel] class that all view models should extend.
///
abstract class ViewModel extends LifecycleProvider implements LifecycleListener {
  /// The context associated with the ViewModelProvider that initialized this ViewModel.
  ///
  BuildContext _context;
  BuildContext get context => _context;

  /// A utility method to publish events to other ViewModels.
  /// Note: the current ViewModel will not be notified of the event published by this method.
  ///
  void Function(dynamic event) _publishEvent;
  void Function(dynamic event) get publishEvent => _publishEvent;

  /// A method called when this [ViewModel] gets initialized.
  ///
  /// The lifecycle of the [ViewModel] is bound to the lifecycle of its [ViewModelProvider].
  ///
  @override
  void onInit() {}

  /// A method called when this [ViewModel] gets disposed.
  ///
  /// The lifecycle of the [ViewModel] is bound to the lifecycle of its [ViewModelProvider].
  ///
  @override
  void onDispose() {}

  /// A method called when a new event is published either by a different [ViewModel]
  /// or by calling the publish method on a [ViewModelProvider].
  ///
  void onEvent(dynamic event) {}
}
