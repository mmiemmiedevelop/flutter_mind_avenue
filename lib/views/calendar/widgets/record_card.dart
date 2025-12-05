import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:moodavenue/widgets/card_container.dart';

/// 내가 남긴 기록 카드
class RecordCard extends StatelessWidget {
  const RecordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('내가 남긴 기록', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Text(
            '선택한 날짜의 기록이 여기에 표시됩니다.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

