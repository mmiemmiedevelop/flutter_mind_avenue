import 'package:flutter/material.dart';

/// ---- 공통 아이콘 배지 -----------------------------------------------------
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A1C1E21),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF6B6F76)),
    );
  }
}
