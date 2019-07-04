part of view_model;

/// A base [LifecycleListener] class that all lifecycle listeners should extend.
///
abstract class LifecycleListener {
  void onInit();
  void onDispose();
}
