import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';

/// 캘린더의 날짜 셀 위젯
class DayCell extends StatelessWidget {
  final DateTime day;
  final String? emoji;
  final bool isSelected;
  final bool isToday;

  const DayCell({
    super.key,
    required this.day,
    required this.emoji,
    required this.isSelected,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: isSelected || isToday
            ? BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(emoji ?? '', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

