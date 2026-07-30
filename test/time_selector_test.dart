import 'package:atomic_task/features/timer/presentation/widgets/time_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('commits only the final value after scrolling stops', (
    tester,
  ) async {
    final selectedValues = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TimeSelector(
              value: 25,
              maxValue: 120,
              onChanged: selectedValues.add,
              enabled: true,
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(TimeSelector), const Offset(0, -180));

    expect(selectedValues, isEmpty);

    await tester.pumpAndSettle();

    expect(selectedValues, hasLength(1));
    expect(selectedValues.single, isNot(25));
  });
}
