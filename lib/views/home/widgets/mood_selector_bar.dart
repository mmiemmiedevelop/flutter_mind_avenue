import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:confetti/confetti.dart';
import 'package:moodavenue/services/firebase.dart';

/// ---- MOOD 선택 바 ----------------------------------------------------------
class MoodSelectorBar extends StatefulWidget {
  final int? initialMoodLevel;
  final bool isReadOnly;

  const MoodSelectorBar({
    super.key,
    this.initialMoodLevel,
    this.isReadOnly = false,
  });

  @override
  State<MoodSelectorBar> createState() => _MoodSelectorBarState();
}

class _MoodSelectorBarState extends State<MoodSelectorBar>
    with SingleTickerProviderStateMixin {
  final List<String> _emojis = ['😁', '😇', '😐', '😢', '😡'];
  final List<Color> _moodColors = [
    AppColors.moodJoy, // 😁 - 따뜻한 노랑
    AppColors.moodCalm, // 😇 - 편안한 민트
    AppColors.moodPeaceful, // 😐 - 평온한 모카
    AppColors.moodSad, // 😢 - 차분한 블루그레이
    AppColors.error, // 😡 - 강렬한 레드/오렌지 계열
  ];

  // 긍정적인 감정에만 컨페티 효과 (😁, 😌)
  final List<List<Color>> _confettiColors = [
    // 😁 기쁨 - 밝고 화사한 노랑/오렌지 계열
    [
      Color(0xFFFFC857), // 밝은 노랑
      Color(0xFFFFFAF0), // 거의 흰색 (아이보리)
      Color(0xFFFFD000), // 순수 골드 (원톤)
      Color(0xFFFFA500), // 오렌지
      Color(0xFFFFB347), // 파스텔 오렌지
    ],
    // 😌 평온 - 부드러운 연한 초록 계열
    [
      Color(0xFF00C853), // 순수 그린 (원톤)
      Color(0xFFA8D5BA), // 민트 그린
      Color(0xFFB8E6C9), // 연한 민트
      Color(0xFF9FC99F), // 파스텔 그린
      Color(0xFFF5FFF5), // 거의 흰색 (민트 화이트)
    ],
  ];

  int _selectedIndex = -1; // -1은 아무것도 선택되지 않음
  late List<ConfettiController> _confettiControllers;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;

  final FirebaseService _firebaseService = FirebaseService();
  bool _isSaving = false; // 저장 중 상태

  @override
  void initState() {
    super.initState();

    // 초기값 설정 (moodLevel 1-5를 index 0-4로 변환)
    if (widget.initialMoodLevel != null) {
      _selectedIndex = widget.initialMoodLevel! - 1;
    }

    // 첫 2개 감정(😁, 😇)에만 컨페티 컨트롤러 생성
    _confettiControllers = List.generate(
      2,
      (index) => ConfettiController(duration: const Duration(seconds: 1)),
    );

    // 부정적 감정(😢, 😡)용 scale 애니메이션 컨트롤러
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    // 모든 컨트롤러 해제
    for (var controller in _confettiControllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Firebase에 기분 저장
  Future<void> _saveMood(int index) async {
    if (_isSaving) return; // 이미 저장 중이면 무시

    setState(() => _isSaving = true);

    try {
      // index는 0-4, moodLevel은 1-5 (1=매우좋음, 5=매우나쁨)
      final moodLevel = index + 1;
      await _firebaseService.saveTodayMood(moodLevel: moodLevel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오늘의 기분이 저장되었어요 ${_emojis[index]}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _moodColors[index],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했어요. 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _selectedIndex != -1
                ? _moodColors[_selectedIndex].withOpacity(0.15)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_emojis.length, (index) {
              final bool isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: (_isSaving || widget.isReadOnly)
                    ? () {
                        // 읽기 전용일 때 알림 표시
                        if (widget.isReadOnly) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('오늘의 기분은 이미 기록되었어요 😊'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    : () {
                        setState(() => _selectedIndex = index);

                        // 첫 2개 감정(😁, 😇)만 컨페티 효과
                        if (index < 2) {
                          _confettiControllers[index].play();
                        }
                        // 부정적 감정(😢, 😡)은 scale 애니메이션
                        else if (index >= 3) {
                          _shakeController.forward(from: 0);
                        }

                        // Firebase에 저장
                        _saveMood(index);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _moodColors[index]
                        : _moodColors[index].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _moodColors[index].withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: index >= 3
                      ? AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSelected ? _scaleAnimation.value : 1.0,
                              child: Text(
                                _emojis[index],
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 20,
                                ),
                              ),
                            );
                          },
                        )
                      : Text(
                          _emojis[index],
                          style: TextStyle(fontSize: isSelected ? 22 : 20),
                        ),
                ),
              );
            }),
          ),
        ),
        // 긍정적인 감정에만 Confetti 효과 (😁, 😌)
        ...List.generate(2, (index) {
          return Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiControllers[index],
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: _confettiColors[index],
              gravity: 0.1,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
            ),
          );
        }),
      ],
    );
  }
}
