import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';

/// ---- AD 플레이스홀더 -------------------------------------------------------
class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: const Center(
        child: Text('광고 영역', style: TextStyle(color: AppColors.textTertiary)),
      ),
    );
  }
}
