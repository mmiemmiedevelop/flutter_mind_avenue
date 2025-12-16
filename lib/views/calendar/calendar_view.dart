import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/views/calendar/widgets/calendar_card.dart';
import 'package:moodavenue/views/calendar/widgets/record_card.dart';
import 'package:moodavenue/views/calendar/widgets/monthly_mood_card.dart';
import 'package:moodavenue/services/firebase.dart';
import 'package:moodavenue/models/mood_record.dart';

/// 만년달력: 기본 캘린더(table_calendar) + 날짜별 이모지 표시
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, MoodRecord> _moodsByDay = {};
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadMonthlyMoods(_focusedDay);
  }

  /// moodLevel을 이모지로 변환
  String _moodLevelToEmoji(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return '😁'; // 매우 좋음
      case 2:
        return '😇'; // 좋음
      case 3:
        return '😐'; // 보통
      case 4:
        return '😢'; // 나쁨
      case 5:
        return '😡'; // 매우 나쁨
      default:
        return '';
    }
  }

  /// Firestore에서 한 달 기분 데이터 가져오기
  Future<void> _loadMonthlyMoods(DateTime month) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 해당 월의 첫날과 마지막 날 계산
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Firestore에서 데이터 가져오기
      final moods = await _firebaseService.getMoodsByDateRange(
        startDate: firstDay,
        endDate: lastDay,
      );

      // 기존 데이터 초기화하고 새 데이터로 채우기
      _moodsByDay.clear();
      for (final mood in moods) {
        final dateKey = DateTime(
          mood.date.year,
          mood.date.month,
          mood.date.day,
        );
        _moodsByDay[dateKey] = mood;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터를 불러오는데 실패했어요: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 날짜 비교 헬퍼 (연-월-일 단위)
  bool _isSameDay(DateTime? a, DateTime? b) =>
      a != null && b != null && isSameDay(a, b);

  /// MoodRecord에서 이모지 맵 생성
  Map<DateTime, String> _getEmojiByDay() {
    return _moodsByDay.map(
      (date, mood) => MapEntry(date, _moodLevelToEmoji(mood.moodLevel)),
    );
  }

  /// 선택된 날짜의 note 가져오기
  String? _getSelectedNote() {
    if (_selectedDay == null) return null;
    final dateKey = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    return _moodsByDay[dateKey]?.note;
  }

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
        child: Stack(
          children: [
            Padding(
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
                          emojiByDay: _getEmojiByDay(),
                          onDaySelected: _handleDaySelected,
                          onPageChanged: _handlePageChanged,
                          isSameDay: _isSameDay,
                        ),
                        const SizedBox(height: 12),
                        RecordCard(note: _getSelectedNote()),
                        const SizedBox(height: 12),
                        MonthlyMoodCard(
                          moodRecords: _moodsByDay.values.toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
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
    // 새로운 월의 데이터 로드
    _loadMonthlyMoods(focusedDay);
  }
}
