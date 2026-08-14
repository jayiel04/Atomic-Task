import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProgressDetailSheet extends StatelessWidget {
  const ProgressDetailSheet({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.accentColor,
    required this.accentSurface,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;
  final Color accentColor;
  final Color accentSurface;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              key: const Key('progressDetailValue'),
              maxLines: 1,
              style: TextStyle(
                color: accentColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('closeProgressDetailButton'),
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor.withValues(alpha: 0.45)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
