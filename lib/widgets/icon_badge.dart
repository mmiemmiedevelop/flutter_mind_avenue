import 'package:flutter/material.dart';

/// ---- 공통 아이콘 배지 -----------------------------------------------------
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A1C1E21),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6B6F76)),
        ),
      ),
    );
  }
}
