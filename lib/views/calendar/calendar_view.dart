import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// 만년달력: 기본 캘린더(table_calendar) + 날짜별 이모지 표시
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  // 날짜별 이모지 데이터 (샘플)
  // 실제로는 로컬/서버/DB 연동하여 로드하면 됩니다.
  final Map<DateTime, String> _emojiByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // 데모용: 이번 달 며칠에 임의 이모지 채우기
    final now = DateTime.now();
    for (int i = 1; i <= 28; i++) {
      final date = DateTime(now.year, now.month, i);
      if (i % 3 == 0) _emojiByDay[date] = '😊';
      if (i % 5 == 0) _emojiByDay[date] = '😌';
      if (i % 7 == 0) _emojiByDay[date] = '🥲';
    }
  }

  // day 키를 map에서 안정적으로 찾기 위한 헬퍼 (연-월-일 단위로 비교)
  bool _isSameDay(DateTime? a, DateTime? b) =>
      a != null && b != null && isSameDay(a, b);

  String? _emojiForDay(DateTime day) {
    // 연-월-일만 유지
    final key = DateTime(day.year, day.month, day.day);
    return _emojiByDay[key];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('캘린더'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF121417),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 가용 너비를 기준으로 셀 높이를 산출하여 다양한 화면에서 자동 레이아웃
              final availableWidth = constraints.maxWidth - 16; // 컨테이너 내부 여백 감안
              final computedRowHeight = (availableWidth / 7) * 0.9;
              final rowHeight = computedRowHeight.clamp(44.0, 56.0);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: TableCalendar<String>(
                    rowHeight: rowHeight.toDouble(),
                    daysOfWeekHeight: (rowHeight * 0.5).toDouble(),
                    firstDay: DateTime.utc(1970, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF6B6F76),
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF6B6F76),
                      ),
                      titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF121417),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      todayDecoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF2F6BFF),
                          width: 2,
                        ),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color(0xFF2F6BFF).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xFF2F6BFF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      outsideDaysVisible: true,
                      defaultTextStyle: const TextStyle(fontSize: 12),
                      weekendTextStyle: const TextStyle(fontSize: 12),
                      disabledTextStyle: const TextStyle(fontSize: 12),
                    ),
                    selectedDayPredicate: (day) =>
                        _isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    calendarBuilders: CalendarBuilders<String>(
                      defaultBuilder: (context, day, focusedDay) => _DayCell(
                        day: day,
                        emoji: _emojiForDay(day),
                        isSelected: _isSameDay(day, _selectedDay),
                      ),
                      todayBuilder: (context, day, focusedDay) => _DayCell(
                        day: day,
                        emoji: _emojiForDay(day),
                        isSelected: _isSameDay(day, _selectedDay),
                        isToday: true,
                      ),
                      selectedBuilder: (context, day, focusedDay) => _DayCell(
                        day: day,
                        emoji: _emojiForDay(day),
                        isSelected: true,
                      ),
                      outsideBuilder: (context, day, focusedDay) => Opacity(
                        opacity: 0.4,
                        child: _DayCell(
                          day: day,
                          emoji: _emojiForDay(day),
                          isSelected: _isSameDay(day, _selectedDay),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final String? emoji;
  final bool isSelected;
  final bool isToday;

  const _DayCell({
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
                border: Border.all(color: const Color(0xFF2F6BFF), width: 2),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF222222),
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
