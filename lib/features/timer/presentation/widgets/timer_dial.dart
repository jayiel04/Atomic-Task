import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../controllers/timer_controller.dart';
import '../layout/timer_layout_spec.dart';
import 'time_selector.dart';

class TimerDial extends StatelessWidget {
  const TimerDial({required this.controller, required this.spec, super.key});

  final TimerController controller;
  final TimerLayoutSpec spec;

  @override
  Widget build(BuildContext context) {
    final heading = switch ((
      controller.isRunning,
      controller.sessionCompleted,
    )) {
      (true, _) => controller.mode.title,
      (false, true) => 'SESIÓN COMPLETADA',
      _ => 'AJUSTA TU TIEMPO',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableSize = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final size = availableSize < spec.dialMinSize
            ? availableSize
            : availableSize
                  .clamp(spec.dialMinSize, spec.dialMaxSize)
                  .toDouble();
        final clockFontSize = size < 240
            ? 28.0
            : size < 300
            ? 36.0
            : 42.0;
        final selectorHeight = math.min(spec.timeSelectorHeight, size * 0.37);
        final dialPadding = size < 220 ? size * 0.06 : size * 0.08;
        final headingGap = size < 220 ? 4.0 : 10.0;
        final selectorGap = size < 220 ? 6.0 : 16.0;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 3,
                right: 18,
                child: Transform.rotate(
                  angle: 0.72,
                  child: Container(
                    width: 58,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(dialPadding),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceVariant,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.62),
                      width: 5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x29513382),
                        blurRadius: 45,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          heading,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: size < 240 ? 11 : 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        SizedBox(height: headingGap),
                        Text(
                          TimeFormatter.clock(controller.remainingSeconds),
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: clockFontSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: selectorGap),
                        SizedBox(
                          width: size * 0.64,
                          child: TimeSelector(
                            value: controller.minutes,
                            maxValue: TimerConstants.maximumMinutes,
                            onChanged: controller.setMinutes,
                            enabled: !controller.controlsLocked,
                            height: selectorHeight,
                            itemExtent: spec.timeItemExtent,
                            fontSize: spec.timeFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
