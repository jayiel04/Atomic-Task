import 'package:flutter/material.dart';

enum TimerLayoutMode { regular, compact, tablet, landscape }

/// Presentation-only dimensions for the timer screen.
///
/// Keeping these values together prevents responsive decisions from leaking
/// into the timer controller or being repeated in every widget.
class TimerLayoutSpec {
  const TimerLayoutSpec({
    required this.mode,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.sectionGap,
    required this.controlGap,
    required this.modeHeight,
    required this.statusMinHeight,
    required this.primaryButtonHeight,
    required this.primaryIconSize,
    required this.primaryFontSize,
    required this.resetButtonHeight,
    required this.dialMinSize,
    required this.dialMaxSize,
    required this.timeSelectorHeight,
    required this.timeItemExtent,
    required this.timeFontSize,
    required this.maxContentWidth,
  });

  final TimerLayoutMode mode;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double sectionGap;
  final double controlGap;
  final double modeHeight;
  final double statusMinHeight;
  final double primaryButtonHeight;
  final double primaryIconSize;
  final double primaryFontSize;
  final double resetButtonHeight;
  final double dialMinSize;
  final double dialMaxSize;
  final double timeSelectorHeight;
  final double timeItemExtent;
  final double timeFontSize;
  final double maxContentWidth;

  bool get isCompact => mode == TimerLayoutMode.compact;
  bool get isTablet => mode == TimerLayoutMode.tablet;
  bool get isLandscape => mode == TimerLayoutMode.landscape;

  factory TimerLayoutSpec.from(BoxConstraints constraints) {
    final isLandscape = constraints.maxWidth > constraints.maxHeight;

    if (isLandscape) {
      return const TimerLayoutSpec(
        mode: TimerLayoutMode.landscape,
        horizontalPadding: 16,
        topPadding: 8,
        bottomPadding: 8,
        sectionGap: 8,
        controlGap: 1,
        modeHeight: 44,
        statusMinHeight: 36,
        primaryButtonHeight: 48,
        primaryIconSize: 30,
        primaryFontSize: 16,
        resetButtonHeight: 44,
        dialMinSize: 180,
        dialMaxSize: 280,
        timeSelectorHeight: 120,
        timeItemExtent: 44,
        timeFontSize: 36,
        maxContentWidth: 720,
      );
    }

    if (constraints.maxWidth >= 600) {
      const horizontalPadding = 32.0;

      return TimerLayoutSpec(
        mode: TimerLayoutMode.tablet,
        horizontalPadding: horizontalPadding,
        topPadding: 20,
        bottomPadding: 24,
        sectionGap: 20,
        controlGap: 16,
        modeHeight: 56,
        statusMinHeight: 52,
        primaryButtonHeight: 64,
        primaryIconSize: 32,
        primaryFontSize: 19,
        resetButtonHeight: 48,
        dialMinSize: 340,
        dialMaxSize: 420,
        timeSelectorHeight: 170,
        timeItemExtent: 50,
        timeFontSize: 44,
        maxContentWidth: constraints.maxWidth - horizontalPadding * 2,
      );
    }

    final isCompact = constraints.maxHeight < 700 || constraints.maxWidth < 360;

    if (isCompact) {
      return const TimerLayoutSpec(
        mode: TimerLayoutMode.compact,
        horizontalPadding: 16,
        topPadding: 8,
        bottomPadding: 8,
        sectionGap: 8,
        controlGap: 6,
        modeHeight: 48,
        statusMinHeight: 42,
        primaryButtonHeight: 50,
        primaryIconSize: 30,
        primaryFontSize: 16,
        resetButtonHeight: 44,
        dialMinSize: 200,
        dialMaxSize: 280,
        timeSelectorHeight: 120,
        timeItemExtent: 44,
        timeFontSize: 36,
        maxContentWidth: 520,
      );
    }

    return const TimerLayoutSpec(
      mode: TimerLayoutMode.regular,
      horizontalPadding: 24,
      topPadding: 18,
      bottomPadding: 20,
      sectionGap: 16,
      controlGap: 10,
      modeHeight: 56,
      statusMinHeight: 52,
      primaryButtonHeight: 64,
      primaryIconSize: 32,
      primaryFontSize: 19,
      resetButtonHeight: 48,
      dialMinSize: 280,
      dialMaxSize: 340,
      timeSelectorHeight: 150,
      timeItemExtent: 50,
      timeFontSize: 42,
      maxContentWidth: 520,
    );
  }
}
