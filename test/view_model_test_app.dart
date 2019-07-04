library view_model_test_app;

import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

class IncrementEvent {
  IncrementEvent(this.value);
  final int value;
}

class CounterViewModel extends ViewModel {
  final ValueNotifier<int> counter = ValueNotifier<int>(null);

  @override
  void onInit() {
    counter.value = 0;
  }

  @override
  void onDispose() {
    counter.value = null;
  }

  @override
  void onEvent(dynamic event) {
    if (event is IncrementEvent) {
      counter.value = counter.value + event.value;
    }
  }

  void increment({bool shouldPublishEvent = false}) {
    counter.value = counter.value + 1;
    if (shouldPublishEvent) {
      publishEvent(IncrementEvent(1));
    }
  }
}

class CustomLifecycleListener extends LifecycleListener {
  int onInitCounter = 0;
  int onDisposeCounter = 0;

  @override
  void onInit() {
    onInitCounter++;
  }

  @override
  void onDispose() {
    onDisposeCounter++;
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({
    Key key,
    this.title = 'Counter',
    this.viewModel,
    this.shouldPublishEvent = false,
    this.nextPageBuilder,
  }) : super(key: key);

  final String title;
  final ViewModelFactory<CounterViewModel> viewModel;
  final bool shouldPublishEvent;
  final WidgetBuilder nextPageBuilder;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CounterViewModel>(
      viewModel: viewModel,
      builder: (BuildContext context, CounterViewModel viewModel) {
        return ValueListenableBuilder<int>(
          valueListenable: viewModel.counter,
          builder: (BuildContext context, int value, _) {
            return Scaffold(
              appBar: _buildAppBar(context),
              floatingActionButton: _buildFloatingActionButton(viewModel),
              body: _buildBody(value),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: nextPageBuilder != null
          ? <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_right),
                tooltip: 'Next',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: nextPageBuilder,
                    ),
                  );
                },
              )
            ]
          : null,
    );
  }

  FloatingActionButton _buildFloatingActionButton(CounterViewModel viewModel) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      tooltip: 'Increment',
      onPressed: () {
        viewModel.increment(shouldPublishEvent: shouldPublishEvent);
      },
    );
  }

  Center _buildBody(int value) {
    return Center(
      child: Text(value.toString()),
    );
  }
}

class TestApp extends StatelessWidget {
  const TestApp({Key key, @required this.home}) : super(key: key);

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: home,
    );
  }
}

class ActionViewModel extends ViewModel {
  ActionViewModel({Duration delayDuration}) {
    multiplyAction = Action<int, int>(this, (int value) async {
      if (value > 0) {
        if (delayDuration != null) {
          await Future<void>.delayed(delayDuration);
        }
        return await Future<int>.value(value * value);
      } else {
        return await Future<int>.error('Value must be above 0.');
      }
    });
  }

  Action<int, int> multiplyAction;

  @override
  void onInit() {
    multiplyAction.perform(input: 2);
  }

  void multiply(int value) {
    if (value > 0) {
      multiplyAction.perform(input: value);
    } else {
      multiplyAction.tryPerform(input: value);
    }
  }
}

class MultiplyPage extends StatelessWidget {
  const MultiplyPage({
    Key key,
    this.viewModel,
    this.useStream = false,
  }) : super(key: key);

  final ViewModelFactory<ActionViewModel> viewModel;
  final bool useStream;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ActionViewModel>(
      viewModel: viewModel,
      builder: (BuildContext context, ActionViewModel viewModel) {
        return Scaffold(
          body: useStream ? _buildBodyStreamBuilder(viewModel) : _buildBodyActionBuilder(viewModel),
        );
      },
    );
  }

  Widget _buildBodyStreamBuilder(ActionViewModel viewModel) {
    return StreamBuilder<Result<int>>(
      stream: viewModel.multiplyAction.stream,
      builder: (BuildContext context, AsyncSnapshot<Result<int>> snapshot) {
        if (snapshot.hasData && snapshot.data.hasValue) {
          final int value = snapshot.data.value;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(value.toString()),
                FlatButton(
                  child: Text('Multiply $value'),
                  onPressed: () {
                    viewModel.multiply(value);
                  },
                ),
                FlatButton(
                  child: const Text('Multiply 0'),
                  onPressed: () {
                    viewModel.multiply(0);
                  },
                )
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error),
          );
        } else {
          return const Center(
            child: Text('Awaiting result...'),
          );
        }
      },
    );
  }

  ActionBuilder<int, int> _buildBodyActionBuilder(ActionViewModel viewModel) {
    return ActionBuilder<int, int>(
      action: viewModel.multiplyAction,
      builder: (BuildContext context, Result<int> result) {
        if (result.hasValue) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(result.value.toString()),
                FlatButton(
                  child: Text('Multiply ${result.value}'),
                  onPressed: () {
                    viewModel.multiply(result.value);
                  },
                ),
                FlatButton(
                  child: const Text('Multiply 0'),
                  onPressed: () {
                    viewModel.multiply(0);
                  },
                )
              ],
            ),
          );
        } else if (result.isAwaiting) {
          return const Center(
            child: Text('Awaiting result...'),
          );
        } else if (result.hasError) {
          return Center(
            child: Text(result.error),
          );
        }
      },
    );
  }
}
