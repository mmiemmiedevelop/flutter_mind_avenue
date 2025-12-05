import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';

/// ---- 공통 아이콘 배지 -----------------------------------------------------
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    return Material(
      color: AppColors.surface,
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}
