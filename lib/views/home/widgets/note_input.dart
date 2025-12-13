import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

/// ---- NOTE 입력 -------------------------------------------------------------
class NoteInput extends StatefulWidget {
  const NoteInput({super.key});

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 포커스가 생길 때 스크롤 위치 조정
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // 키보드가 완전히 올라올 때까지 대기
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (!mounted) return;

            // 위젯을 화면에 표시하되, 추가 여백을 주기 위해 alignment 사용
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.0, // 화면 최상단
              alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
            ).then((_) {
              // 스크롤 완료 후 추가로 더 스크롤
              if (!mounted) return;

              final scrollable = Scrollable.of(context);
              final currentPosition = scrollable.position.pixels;
              final maxScroll = scrollable.position.maxScrollExtent;

              // 현재 위치에서 200픽셀 더 스크롤
              final targetPosition = (currentPosition + 200).clamp(
                0.0,
                maxScroll,
              );

              scrollable.position.jumpTo(targetPosition);
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done, // 엔터키를 '완료' 버튼으로 표시
        onSubmitted: (_) {
          // 엔터키 누르면 포커스 해제 (키보드 내림)
          _focusNode.unfocus();
        },
        style: AppTextStyles.body16Regular.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration.collapsed(
          hintText: '솔직한 내 오늘의 기분을 적어보세요',
          hintStyle: AppTextStyles.body16Regular.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
