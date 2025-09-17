import 'package:flutter/material.dart';

/// ---- MOOD 선택 바 ----------------------------------------------------------
class MoodSelectorBar extends StatefulWidget {
  const MoodSelectorBar({super.key});

  @override
  State<MoodSelectorBar> createState() => _MoodSelectorBarState();
}

class _MoodSelectorBarState extends State<MoodSelectorBar> {
  final List<String> _emojis = ['😊', '🙂', '😐', '🙁', '😡'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_emojis.length, (index) {
          final bool isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x141C1E21),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _emojis[index],
                style: TextStyle(fontSize: isSelected ? 22 : 20),
              ),
            ),
          );
        }),
      ),
    );
  }
}
