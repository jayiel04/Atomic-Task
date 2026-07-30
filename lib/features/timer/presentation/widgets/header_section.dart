import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../controllers/timer_controller.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({
    required this.controller,
    super.key,
  });

  final TimerController controller;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.controller.progress.profileName,
    );
    _nameFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant HeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentName = widget.controller.progress.profileName;
    if (_nameController.text != currentName && !_nameFocusNode.hasFocus) {
      _nameController.text = currentName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            return _SquareButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu_rounded),
            );
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              _ProfileCard(
                nameController: _nameController,
                focusNode: _nameFocusNode,
                onSubmitted: widget.controller.updateProfileName,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.diamond_rounded,
                      value: widget.controller.progress.gems.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.schedule_rounded,
                      value: TimeFormatter.totalFocus(
                        widget.controller.progress.totalFocusSeconds,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.nameController,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController nameController;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1C513382),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-4, 0),
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 42,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: nameController,
              focusNode: focusNode,
              maxLength: 18,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: onSubmitted,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
                onSubmitted(nameController.text);
              },
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
              decoration: const InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.only(right: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(17),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1C513382),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconTheme(
            data: const IconThemeData(
              color: AppColors.primary,
              size: 28,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
