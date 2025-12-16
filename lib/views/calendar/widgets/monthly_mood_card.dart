import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/widgets/card_container.dart';
import 'package:moodavenue/models/mood_record.dart';

/// 이번달 평균 기분 카드
class MonthlyMoodCard extends StatelessWidget {
  final List<MoodRecord> moodRecords;

  const MonthlyMoodCard({super.key, required this.moodRecords});

  /// moodLevel별 카운트 계산
  Map<int, int> _getMoodCounts() {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final record in moodRecords) {
      counts[record.moodLevel] = (counts[record.moodLevel] ?? 0) + 1;
    }
    return counts;
  }

  /// moodLevel에 따른 색상 반환
  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return const Color(0xFF7ED957); // 밝은 초록 (매우 좋음)
      case 2:
        return const Color(0xFF6EC4DB); // 청록색 (좋음)
      case 3:
        return const Color(0xFFE8B17F); // 베이지 (보통)
      case 4:
        return const Color(0xFFEF9A6A); // 주황 (나쁨)
      case 5:
        return const Color(0xFFD47264); // 빨강 (매우 나쁨)
      default:
        return AppColors.surface;
    }
  }

  /// moodLevel에 따른 이모지 반환
  String _getMoodEmoji(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return '😁';
      case 2:
        return '😇';
      case 3:
        return '😐';
      case 4:
        return '😢';
      case 5:
        return '😡';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getMoodCounts();
    final hasData = moodRecords.isNotEmpty;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번달 평균 기분', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  '이번 달 기록이 없습니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final moodLevel = index + 1;
                  final count = counts[moodLevel] ?? 0;
                  // 1개당 5%, 최대 100%
                  final percentage = (count * 0.05).clamp(0.0, 1.0);
                  final barHeight = 140 * percentage;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // 배경 막대 (밝은 회색)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight.withOpacity(
                                    0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: _getMoodColor(moodLevel),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 이모지 (데이터가 있으면 막대 위, 없으면 하단)
                            Positioned(
                              bottom: count > 0 ? barHeight + 8 : 8,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _getMoodColor(moodLevel),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _getMoodEmoji(moodLevel),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
