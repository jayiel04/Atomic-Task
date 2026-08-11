import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../controllers/timer_controller.dart';
import '../layout/timer_layout_spec.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({
    required this.controller,
    required this.spec,
    super.key,
  });

  final TimerController controller;
  final TimerLayoutSpec spec;

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
    if (widget.spec.isLandscape) {
      return _buildCompactHeader();
    }

    if (widget.spec.isCompact) {
      return _buildCompactHeader();
    }

    if (widget.spec.isTablet) {
      return _buildTabletHeader();
    }

    return _buildRegularHeader();
  }

  Widget _buildRegularHeader() {
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
        Expanded(child: _buildProfileAndStats()),
      ],
    );
  }

  Widget _buildTabletHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final profileSectionWidth = math.min(400.0, constraints.maxWidth - 70);

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
            const Spacer(),
            SizedBox(
              width: profileSectionWidth,
              child: _buildProfileAndStats(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAndStats() {
    return Column(
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
    );
  }

  Widget _buildCompactHeader({bool showStats = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 54,
          child: Row(
            children: [
              _SquareButton(
                size: 48,
                iconSize: 24,
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileCard(
                  height: 54,
                  avatarSize: 54,
                  avatarIconSize: 32,
                  contentPadding: const EdgeInsets.only(right: 8),
                  nameController: _nameController,
                  focusNode: _nameFocusNode,
                  onSubmitted: widget.controller.updateProfileName,
                ),
              ),
            ],
          ),
        ),
        if (showStats) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  compact: true,
                  icon: Icons.diamond_rounded,
                  value: widget.controller.progress.gems.toString(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  compact: true,
                  icon: Icons.schedule_rounded,
                  value: TimeFormatter.totalFocus(
                    widget.controller.progress.totalFocusSeconds,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.nameController,
    required this.focusNode,
    required this.onSubmitted,
    this.height = 62,
    this.avatarSize = 66,
    this.avatarIconSize = 42,
    this.contentPadding = const EdgeInsets.only(right: 16),
  });

  final TextEditingController nameController;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final double height;
  final double avatarSize;
  final double avatarIconSize;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: avatarIconSize,
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
              decoration: InputDecoration(
                counterText: '',
                contentPadding: contentPadding,
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
    this.size = 54,
    this.iconSize = 28,
  });

  final VoidCallback onPressed;
  final Widget child;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: size,
          height: size,
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
            data: IconThemeData(color: AppColors.primary, size: iconSize),
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
    this.compact = false,
  });

  final IconData icon;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 34 : 52),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 14,
        vertical: compact ? 2 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: compact ? 18 : 26),
          SizedBox(width: compact ? 6 : 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 6 : 12,
                vertical: compact ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(compact ? 8 : 10),
              ),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12 : 15,
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
