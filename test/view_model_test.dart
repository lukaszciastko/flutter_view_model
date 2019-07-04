import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:view_model/view_model.dart';
import 'view_model_test_app.dart';

void main() {
  testWidgets('ViewModel - single (ViewModelBuilder)', (WidgetTester tester) async {
    final CounterViewModel viewModel = CounterViewModel();

    final CustomLifecycleListener lifecycleListener = CustomLifecycleListener();
    viewModel.addLifecycleListener(lifecycleListener);

    final Widget app = TestApp(
      home: CounterPage(
        viewModel: () => viewModel,
      ),
    );

    await tester.pumpWidget(app);
    await _testSingleViewModel(tester, viewModel, lifecycleListener);
  });

  testWidgets('ViewModel - single (ViewModelProvider)', (WidgetTester tester) async {
    final CounterViewModel viewModel = CounterViewModel();

    final CustomLifecycleListener lifecycleListener = CustomLifecycleListener();
    viewModel.addLifecycleListener(lifecycleListener);

    final Widget app = ViewModelProvider(
      viewModel: () => viewModel,
      child: const TestApp(
        home: CounterPage(),
      ),
    );

    await tester.pumpWidget(app);
    await _testSingleViewModel(tester, viewModel, lifecycleListener);
  });

  testWidgets('ViewModel - multiple (ViewModelBuilder)', (WidgetTester tester) async {
    final CounterViewModel viewModel1 = CounterViewModel();
    final CounterViewModel viewModel2 = CounterViewModel();

    final CustomLifecycleListener lifecycleListener1 = CustomLifecycleListener();
    viewModel1.addLifecycleListener(lifecycleListener1);

    final CustomLifecycleListener lifecycleListener2 = CustomLifecycleListener();
    viewModel2.addLifecycleListener(lifecycleListener2);

    final Widget app = TestApp(
      home: CounterPage(
        viewModel: () => viewModel1,
        nextPageBuilder: (_) => CounterPage(viewModel: () => viewModel2),
      ),
    );

    await tester.pumpWidget(app);
    _testMultipleViewModels(tester, viewModel1, viewModel2, lifecycleListener1, lifecycleListener2);
  });

  testWidgets('ViewModel - multiple (publishEvent)', (WidgetTester tester) async {
    final CounterViewModel viewModel1 = CounterViewModel();
    final CounterViewModel viewModel2 = CounterViewModel();

    final CustomLifecycleListener lifecycleListener1 = CustomLifecycleListener();
    viewModel1.addLifecycleListener(lifecycleListener1);

    final CustomLifecycleListener lifecycleListener2 = CustomLifecycleListener();
    viewModel2.addLifecycleListener(lifecycleListener2);

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: CounterPage(
          viewModel: () => viewModel1,
          shouldPublishEvent: true,
          nextPageBuilder: (_) => CounterPage(
                shouldPublishEvent: true,
                viewModel: () => viewModel2,
              ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    _testMultipleViewModelsEvent(tester, viewModel1, viewModel2, lifecycleListener1, lifecycleListener2);
  });

  testWidgets('ViewModel - shared (ViewModelProvider)', (WidgetTester tester) async {
    final CounterViewModel viewModel = CounterViewModel();

    final Widget app = ViewModelProvider(
      viewModel: () => viewModel,
      child: TestApp(
        home: CounterPage(nextPageBuilder: (_) => const CounterPage()),
      ),
    );

    await tester.pumpWidget(app);
    _testSharedViewModel(tester, viewModel);
  });

  testWidgets('ViewModel - Action (ValueResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel();

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _testActionValueResult(tester, viewModel);
  });

  testWidgets('ViewModel - Action (AwaitingResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel(delayDuration: const Duration(seconds: 1));

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);

    await _testActionAwaitingResult(tester, viewModel);
  });

  testWidgets('ViewModel - Action (ErrorResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel();

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _testActonErrorResult(tester, viewModel);
  });

  testWidgets('ViewModel - Action/Stream (ValueResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel();

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
          useStream: true,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _testActionValueResult(tester, viewModel, testStream: true);
  });

  testWidgets('ViewModel - Action/Stream (AwaitingResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel(delayDuration: const Duration(seconds: 1));

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
          useStream: true,
        ),
      ),
    );

    await tester.pumpWidget(app);

    await _testActionAwaitingResult(tester, viewModel);
  });

  testWidgets('ViewModel - Action/Stream (ErrorResult)', (WidgetTester tester) async {
    final ActionViewModel viewModel = ActionViewModel();

    final Widget app = ViewModelProvider(
      child: TestApp(
        home: MultiplyPage(
          viewModel: () => viewModel,
        ),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await _testActonErrorResult(tester, viewModel);
  });
}

Future<void> _testSingleViewModel(
  WidgetTester tester,
  CounterViewModel viewModel,
  CustomLifecycleListener lifecycleListener,
) async {
  expect(lifecycleListener.onInitCounter, 1);
  expect(lifecycleListener.onDisposeCounter, 0);

  expect(viewModel.context, isA<BuildContext>());

  expect(viewModel.counter.value, 0);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel.counter.value, 1);
  expect(find.text('1'), findsOneWidget);
}

Future<void> _testMultipleViewModels(
  WidgetTester tester,
  CounterViewModel viewModel1,
  CounterViewModel viewModel2,
  CustomLifecycleListener lifecycleListener1,
  CustomLifecycleListener lifecycleListener2,
) async {
  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 0);
  expect(lifecycleListener2.onDisposeCounter, 0);

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isNull);

  expect(viewModel1.counter.value, 0);
  expect(viewModel2.counter.value, null);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isNull);

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, null);
  expect(find.text('1'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 0);

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isA<BuildContext>());

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, 0);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isA<BuildContext>());

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, 2);
  expect(find.text('2'), findsOneWidget);

  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 1);

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isNull);

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, null);
  expect(find.text('1'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isNull);

  expect(viewModel1.counter.value, 2);
  expect(viewModel2.counter.value, null);
  expect(find.text('2'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 1);

  expect(viewModel1.context, isA<BuildContext>());
  expect(viewModel2.context, isA<BuildContext>());

  expect(viewModel1.counter.value, 2);
  expect(viewModel2.counter.value, 0);
  expect(find.text('0'), findsOneWidget);
}

Future<void> _testMultipleViewModelsEvent(
  WidgetTester tester,
  CounterViewModel viewModel1,
  CounterViewModel viewModel2,
  CustomLifecycleListener lifecycleListener1,
  CustomLifecycleListener lifecycleListener2,
) async {
  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 0);
  expect(lifecycleListener2.onDisposeCounter, 0);

  expect(viewModel1.counter.value, 0);
  expect(viewModel2.counter.value, null);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, null);
  expect(find.text('1'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 0);

  expect(viewModel1.counter.value, 1);
  expect(viewModel2.counter.value, 0);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.counter.value, 3);
  expect(viewModel2.counter.value, 2);
  expect(find.text('2'), findsOneWidget);

  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 1);

  expect(viewModel1.counter.value, 3);
  expect(viewModel2.counter.value, null);
  expect(find.text('3'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel1.counter.value, 4);
  expect(viewModel2.counter.value, null);
  expect(find.text('4'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(lifecycleListener1.onInitCounter, 1);
  expect(lifecycleListener1.onDisposeCounter, 0);
  expect(lifecycleListener2.onInitCounter, 1);
  expect(lifecycleListener2.onDisposeCounter, 1);

  expect(viewModel1.counter.value, 4);
  expect(viewModel2.counter.value, 0);
  expect(find.text('0'), findsOneWidget);
}

Future<void> _testSharedViewModel(
  WidgetTester tester,
  CounterViewModel viewModel,
) async {
  expect(viewModel.counter.value, 0);
  expect(find.text('0'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel.counter.value, 1);
  expect(find.text('1'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(viewModel.counter.value, 1);
  expect(find.text('1'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel.counter.value, 3);
  expect(find.text('3'), findsOneWidget);

  await tester.tap(find.byTooltip('Back'));
  await tester.pumpAndSettle();

  expect(viewModel.counter.value, 3);
  expect(find.text('3'), findsOneWidget);

  await tester.tap(find.byTooltip('Increment'));
  await tester.pump();

  expect(viewModel.counter.value, 4);
  expect(find.text('4'), findsOneWidget);

  await tester.tap(find.byTooltip('Next'));
  await tester.pumpAndSettle();

  expect(viewModel.counter.value, 4);
  expect(find.text('4'), findsOneWidget);
}

Future<void> _testActionValueResult(WidgetTester tester, ActionViewModel viewModel, {bool testStream = false}) async {
  if (testStream) {
    expect(viewModel.multiplyAction.stream, isA<Stream<Result<int>>>());
    expect(viewModel.multiplyAction.stream.isBroadcast, isTrue);
  }

  expect(viewModel.multiplyAction.input, 2);
  expect(viewModel.multiplyAction.value, isA<ValueResult<int>>());
  expect(viewModel.multiplyAction.value.value, 4);
  expect(viewModel.multiplyAction.value.error, isNull);
  expect(viewModel.multiplyAction.value.isAwaiting, isFalse);
  expect(viewModel.multiplyAction.value.hasValue, isTrue);
  expect(viewModel.multiplyAction.value.hasError, isFalse);

  expect(find.text('4'), findsOneWidget);
  expect(find.text('Multiply 4'), findsOneWidget);

  await tester.tap(find.text('Multiply 4'));
  await tester.pumpAndSettle();

  expect(viewModel.multiplyAction.input, 4);
  expect(viewModel.multiplyAction.value.value, 16);

  expect(find.text('16'), findsOneWidget);
  expect(find.text('Multiply 16'), findsOneWidget);
}

Future<void> _testActionAwaitingResult(WidgetTester tester, ActionViewModel viewModel) async {
  expect(viewModel.multiplyAction.input, 2);
  expect(viewModel.multiplyAction.value, isA<AwaitingResult<int>>());
  expect(viewModel.multiplyAction.value.value, isNull);
  expect(viewModel.multiplyAction.value.error, isNull);
  expect(viewModel.multiplyAction.value.isAwaiting, isTrue);
  expect(viewModel.multiplyAction.value.hasValue, isFalse);
  expect(viewModel.multiplyAction.value.hasError, isFalse);

  expect(find.text('Awaiting result...'), findsOneWidget);

  await tester.pumpAndSettle(const Duration(seconds: 1));

  expect(viewModel.multiplyAction.input, 2);
  expect(viewModel.multiplyAction.value, isA<ValueResult<int>>());
  expect(viewModel.multiplyAction.value.value, 4);
  expect(viewModel.multiplyAction.value.error, isNull);
  expect(viewModel.multiplyAction.value.isAwaiting, isFalse);
  expect(viewModel.multiplyAction.value.hasValue, isTrue);
  expect(viewModel.multiplyAction.value.hasError, isFalse);

  expect(find.text('4'), findsOneWidget);
  expect(find.text('Multiply 4'), findsOneWidget);

  await tester.tap(find.text('Multiply 4'));
  await tester.pumpAndSettle();

  expect(viewModel.multiplyAction.input, 4);
  expect(viewModel.multiplyAction.value, isA<AwaitingResult<int>>());
  expect(viewModel.multiplyAction.value.value, isNull);
  expect(viewModel.multiplyAction.value.error, isNull);
  expect(viewModel.multiplyAction.value.isAwaiting, isTrue);
  expect(viewModel.multiplyAction.value.hasValue, isFalse);
  expect(viewModel.multiplyAction.value.hasError, isFalse);

  expect(find.text('Awaiting result...'), findsOneWidget);

  await tester.pumpAndSettle(const Duration(seconds: 1));

  expect(viewModel.multiplyAction.input, 4);
  expect(viewModel.multiplyAction.value, isA<ValueResult<int>>());
  expect(viewModel.multiplyAction.value.value, 16);
  expect(viewModel.multiplyAction.value.error, isNull);
  expect(viewModel.multiplyAction.value.isAwaiting, isFalse);
  expect(viewModel.multiplyAction.value.hasValue, isTrue);
  expect(viewModel.multiplyAction.value.hasError, isFalse);

  expect(find.text('16'), findsOneWidget);
  expect(find.text('Multiply 16'), findsOneWidget);
}

Future<void> _testActonErrorResult(WidgetTester tester, ActionViewModel viewModel) async {
  expect(find.text('4'), findsOneWidget);

  await tester.tap(find.text('Multiply 0'));
  await tester.pumpAndSettle();

  expect(viewModel.multiplyAction.input, 0);
  expect(viewModel.multiplyAction.value, isA<ErrorResult<int>>());
  expect(viewModel.multiplyAction.value.value, isNull);
  expect(viewModel.multiplyAction.value.error, 'Value must be above 0.');
  expect(viewModel.multiplyAction.value.isAwaiting, isFalse);
  expect(viewModel.multiplyAction.value.hasValue, isFalse);
  expect(viewModel.multiplyAction.value.hasError, isTrue);

  expect(find.text('Value must be above 0.'), findsOneWidget);
}
