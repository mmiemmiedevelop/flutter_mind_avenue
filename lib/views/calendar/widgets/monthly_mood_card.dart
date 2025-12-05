import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:moodavenue/widgets/card_container.dart';

/// 이번달 평균 기분 카드
class MonthlyMoodCard extends StatelessWidget {
  const MonthlyMoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번달 평균 기분',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 12),
          Text(
            '이번달 평균 기분이 여기에 표시됩니다.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

