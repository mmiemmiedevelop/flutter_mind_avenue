import 'package:flutter/material.dart';

/// ---- AD 플레이스홀더 -------------------------------------------------------
class AdPlaceholder extends StatelessWidget {
  const AdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EE)),
      ),
      child: const Center(
        child: Text('광고 영역', style: TextStyle(color: Color(0xFF8D939C))),
      ),
    );
  }
}
