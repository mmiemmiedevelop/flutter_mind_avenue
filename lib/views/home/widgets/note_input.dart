import 'package:flutter/material.dart';

/// ---- NOTE 입력 -------------------------------------------------------------
class NoteInput extends StatelessWidget {
  const NoteInput({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: 1,
              style: textTheme.bodyMedium,
              decoration: InputDecoration.collapsed(
                hintText: '내 오늘의 기분은 말이지...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFADB3BC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}