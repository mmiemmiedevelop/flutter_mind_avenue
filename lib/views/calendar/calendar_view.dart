import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/views/calendar/widgets/calendar_card.dart';
import 'package:moodavenue/views/calendar/widgets/record_card.dart';
import 'package:moodavenue/views/calendar/widgets/monthly_mood_card.dart';
import 'package:moodavenue/widgets/ad_placeholder.dart';

/// 만년달력: 기본 캘린더(table_calendar) + 날짜별 이모지 표시
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, String> _emojiByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadDemoEmojis();
  }

  /// 데모용 이모지 데이터 로드
  void _loadDemoEmojis() {
    final now = DateTime.now();
    for (int i = 1; i <= 28; i++) {
      final date = DateTime(now.year, now.month, i);
      if (i % 3 == 0) _emojiByDay[date] = '😊';
      if (i % 5 == 0) _emojiByDay[date] = '😌';
      if (i % 7 == 0) _emojiByDay[date] = '🥲';
    }
  }

  /// 날짜 비교 헬퍼 (연-월-일 단위)
  bool _isSameDay(DateTime? a, DateTime? b) =>
      a != null && b != null && isSameDay(a, b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('감정 캘린더'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final rowHeight = _calculateRowHeight(constraints.maxWidth);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CalendarCard(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      rowHeight: rowHeight,
                      emojiByDay: _emojiByDay,
                      onDaySelected: _handleDaySelected,
                      onPageChanged: _handlePageChanged,
                      isSameDay: _isSameDay,
                    ),
                    const SizedBox(height: 12),
                    const RecordCard(),
                    const SizedBox(height: 12),
                    const MonthlyMoodCard(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 화면 너비에 따른 셀 높이 계산
  double _calculateRowHeight(double maxWidth) {
    final availableWidth = maxWidth - 16;
    final computedRowHeight = (availableWidth / 7) * 0.9;
    return computedRowHeight.clamp(44.0, 56.0);
  }

  /// 날짜 선택 처리
  void _handleDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// 페이지 변경 처리
  void _handlePageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }
}
