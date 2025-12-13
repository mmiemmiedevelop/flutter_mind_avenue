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
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      child: Container(
        decoration: isSelected || isToday
            ? BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 11,
              child: Center(
                child: Text(
                  emoji ?? '',
                  style: const TextStyle(fontSize: 11, height: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
