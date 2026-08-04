import 'package:flutter/material.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../controllers/timer_controller.dart';
import 'time_selector.dart';

class TimerDial extends StatelessWidget {
  const TimerDial({required this.controller, super.key});

  final TimerController controller;

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
        final size = constraints.maxWidth.clamp(280.0, 390.0).toDouble();

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
                        color: AppColors.primary.withOpacity(0.6),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(size * 0.08),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceVariant,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.62),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        heading,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        TimeFormatter.clock(controller.remainingSeconds),
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: size < 330 ? 35 : 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: size * 0.64,
                        child: TimeSelector(
                          value: controller.minutes,
                          maxValue: TimerConstants.maximumMinutes,
                          onChanged: controller.setMinutes,
                          enabled: !controller.controlsLocked,
                        ),
                      ),
                    ],
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
