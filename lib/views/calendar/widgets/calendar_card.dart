import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/views/calendar/widgets/day_cell.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

/// 캘린더 카드 위젯
class CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final double rowHeight;
  final Map<DateTime, String> emojiByDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final bool Function(DateTime?, DateTime?) isSameDay;

  const CalendarCard({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.rowHeight,
    required this.emojiByDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.isSameDay,
  });

  String? _emojiForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return emojiByDay[key];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TableCalendar<String>(
        rowHeight: rowHeight,
        daysOfWeekHeight: (rowHeight * 0.5),
        firstDay: DateTime.utc(1970, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: focusedDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        sixWeekMonthsEnforced: true,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
          titleTextStyle: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
          titleTextFormatter: (date, locale) => '${date.year}년 ${date.month}월',
        ),
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 2),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.2),
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          disabledTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders<String>(
          dowBuilder: (context, day) {
            final weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
            return Center(
              child: Text(
                weekdayLabels[day.weekday % 7],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) => DayCell(
            day: day,
            emoji: _emojiForDay(day),
            isSelected: isSameDay(day, selectedDay),
          ),
          todayBuilder: (context, day, focusedDay) => DayCell(
            day: day,
            emoji: _emojiForDay(day),
            isSelected: isSameDay(day, selectedDay),
            isToday: true,
          ),
          selectedBuilder: (context, day, focusedDay) =>
              DayCell(day: day, emoji: _emojiForDay(day), isSelected: true),
          outsideBuilder: (context, day, focusedDay) => Opacity(
            opacity: 0.4,
            child: DayCell(
              day: day,
              emoji: _emojiForDay(day),
              isSelected: isSameDay(day, selectedDay),
            ),
          ),
        ),
      ),
    );
  }
}
