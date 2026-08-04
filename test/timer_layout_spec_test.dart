import 'package:atomic_task/features/timer/presentation/layout/timer_layout_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses compact dimensions for a small portrait screen', () {
    final spec = TimerLayoutSpec.from(
      const BoxConstraints(
        minWidth: 320,
        maxWidth: 320,
        minHeight: 568,
        maxHeight: 568,
      ),
    );

    expect(spec.mode, TimerLayoutMode.compact);
    expect(spec.horizontalPadding, 16);
    expect(spec.primaryButtonHeight, greaterThanOrEqualTo(48));
    expect(spec.dialMaxSize, lessThan(300));
  });

  test('uses regular dimensions for a comfortable portrait screen', () {
    final spec = TimerLayoutSpec.from(
      const BoxConstraints(
        minWidth: 390,
        maxWidth: 390,
        minHeight: 844,
        maxHeight: 844,
      ),
    );

    expect(spec.mode, TimerLayoutMode.regular);
    expect(spec.horizontalPadding, 24);
    expect(spec.maxContentWidth, 520);
    expect(spec.dialMaxSize, greaterThan(300));
  });

  test('uses a landscape layout when width is greater than height', () {
    final spec = TimerLayoutSpec.from(
      const BoxConstraints(
        minWidth: 568,
        maxWidth: 568,
        minHeight: 320,
        maxHeight: 320,
      ),
    );

    expect(spec.mode, TimerLayoutMode.landscape);
    expect(spec.isLandscape, isTrue);
    expect(spec.primaryButtonHeight, greaterThanOrEqualTo(48));
  });

  test('uses a wide tablet layout for a tablet portrait screen', () {
    final spec = TimerLayoutSpec.from(
      const BoxConstraints(
        minWidth: 820,
        maxWidth: 820,
        minHeight: 1180,
        maxHeight: 1180,
      ),
    );

    expect(spec.mode, TimerLayoutMode.tablet);
    expect(spec.isTablet, isTrue);
    expect(spec.maxContentWidth, 756);
    expect(spec.dialMaxSize, greaterThan(340));
  });
}
