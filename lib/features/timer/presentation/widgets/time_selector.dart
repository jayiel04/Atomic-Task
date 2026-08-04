import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimeSelector extends StatefulWidget {
  const TimeSelector({
    required this.value,
    required this.maxValue,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  static const _itemExtent = 50.0;
  static const _selectorHeight = 150.0;

  late final FixedExtentScrollController _scrollController;
  late int _pendingValue;

  @override
  void initState() {
    super.initState();
    _pendingValue = widget.value;
    _scrollController = FixedExtentScrollController(initialItem: widget.value);
  }

  @override
  void didUpdateWidget(covariant TimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _pendingValue = widget.value;
      if (_scrollController.hasClients &&
          _scrollController.selectedItem != widget.value) {
        _scrollController.jumpToItem(widget.value);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _selectorHeight,
      child: RepaintBoundary(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white54,
                Colors.white,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [0, 0.25, 0.5, 0.75, 1],
            ).createShader(bounds);
          },
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              if (widget.enabled && _pendingValue != widget.value) {
                widget.onChanged(_pendingValue);
              }
              return false;
            },
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: _itemExtent,
              diameterRatio: 100,
              perspective: 0.0001,
              physics: widget.enabled
                  ? const FixedExtentScrollPhysics(
                      parent: BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.normal,
                      ),
                    )
                  : const NeverScrollableScrollPhysics(),
              onSelectedItemChanged: widget.enabled
                  ? (value) => _pendingValue = value
                  : null,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.maxValue + 1,
                builder: (context, index) {
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: widget.enabled
                            ? AppColors.text
                            : AppColors.muted.withValues(alpha: 0.45),
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
