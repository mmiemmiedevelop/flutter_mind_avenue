import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:moodavenue/widgets/card_container.dart';

/// 내가 남긴 기록 카드
class RecordCard extends StatelessWidget {
  final String? note;

  const RecordCard({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('내가 남긴 기록', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Text(note ?? '남긴 기록이 없습니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
