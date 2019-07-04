part of view_model;

class LifecycleProvider {
  List<LifecycleListener> _lifecycleListeners;
  List<LifecycleListener> get lifecycleListeners => _lifecycleListeners ??= <LifecycleListener>[];

  void addLifecycleListener(LifecycleListener listener) {
    lifecycleListeners.add(listener);
  }

  void removeLifecycleListener(LifecycleListener listener) {
    _lifecycleListeners.remove(listener);
  }
}
