import 'package:flutter/material.dart';
import 'package:moodavenue/services/firebase.dart';

/// 스플래시 + 사용자 uuid 생성 및 체크
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // 사용자 ID 초기화 (백그라운드에서 실행)
    _initializeUser();

    // 애니메이션 컨트롤러 설정 (2.5초)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 크기 애니메이션: 0.8배 -> 1.2배로 점점 커짐
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 투명도 애니메이션: 0 -> 1 -> 0 (나타났다가 사라짐)
    _opacityAnimation = TweenSequence<double>([
      // 처음 0.3초 동안 나타남
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      // 중간 1초 동안 유지
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      // 마지막 1.2초 동안 사라짐
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 배경색 애니메이션: 흰색 -> 검정색
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFF3B3C35),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 애니메이션 시작
    _controller.forward();

    // 애니메이션 완료 후 홈 화면으로 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  /// 홈 화면으로 이동
  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// 사용자 ID 초기화
  Future<void> _initializeUser() async {
    try {
      final firebaseService = FirebaseService();
      await firebaseService.getUserId();
      //print('✅ 사용자 ID 초기화 완료');
    } catch (e) {
      //print('❌ 사용자 ID 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'lib/theme/image/splash_font_only.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
