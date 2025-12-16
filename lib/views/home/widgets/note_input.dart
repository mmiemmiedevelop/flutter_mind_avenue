import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:moodavenue/services/firebase.dart';

/// ---- NOTE 입력 -------------------------------------------------------------
class NoteInput extends StatefulWidget {
  final String? initialNote;
  final bool isReadOnly;

  const NoteInput({super.key, this.initialNote, this.isReadOnly = false});

  @override
  State<NoteInput> createState() => _NoteInputState();
}

class _NoteInputState extends State<NoteInput> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // 초기값 설정
    if (widget.initialNote != null) {
      _textController.text = widget.initialNote!;
    }

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
    _textController.dispose();
    super.dispose();
  }

  /// Firebase에 노트 저장
  Future<void> _saveNote() async {
    final noteText = _textController.text.trim();

    // 빈 텍스트면 저장하지 않음
    if (noteText.isEmpty) {
      _focusNode.unfocus();
      return;
    }

    if (_isSaving) return; // 이미 저장 중이면 무시

    setState(() => _isSaving = true);

    try {
      await _firebaseService.updateTodayNote(noteText);

      if (mounted) {
        _focusNode.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('메모가 저장되었어요 ✍️'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _focusNode.unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('기분 기록이 없습니다')
                  ? '먼저 기분을 선택해주세요 😊'
                  : '저장에 실패했어요. 다시 시도해주세요.',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        enabled: !_isSaving && !widget.isReadOnly,
        readOnly: widget.isReadOnly,
        textAlignVertical: TextAlignVertical.top,
        textInputAction: TextInputAction.done, // 엔터키를 '완료' 버튼으로 표시
        onTap: widget.isReadOnly
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('오늘의 메모는 이미 기록되었어요 ✍️'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            : null,
        onSubmitted: (_) {
          // 엔터키 누르면 Firebase에 저장
          _saveNote();
        },
        style: AppTextStyles.body16Regular.copyWith(
          color: widget.isReadOnly
              ? AppColors.textSecondary
              : AppColors.textPrimary,
        ),
        decoration: InputDecoration.collapsed(
          hintText: widget.isReadOnly ? '' : '솔직한 내 오늘의 기분을 적어보세요',
          hintStyle: AppTextStyles.body16Regular.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
