import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

/// ---- NOTE 입력 -------------------------------------------------------------
class NoteInput extends StatelessWidget {
  const NoteInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: TextField(
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: AppTextStyles.body16Regular.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration.collapsed(
          hintText: '내 오늘의 기분은 말이지...',
          hintStyle: AppTextStyles.body16Regular.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}