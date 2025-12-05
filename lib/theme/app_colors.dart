import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 컬러 팔레트
/// 따뜻하고 편안한 느낌의 컬러 구성
class AppColors {
  AppColors._(); // private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFFD99058); // 따뜻한 구리색 (액센트)
  static const Color primaryDark = Color(0xFFB67542);
  static const Color primaryLight = Color(0xFFE5A976);

  // Background Colors
  static const Color background = Color(0xFF3B3C35); // 메인 블랙
  static const Color backgroundLight = Color(0xFF4A4B43);
  static const Color backgroundDark = Color(0xFF2A2B26);

  // Surface Colors (카드, 컨테이너 등)
  static const Color surface = Color(0xFF505149);
  static const Color surfaceLight = Color(0xFF656760);
  static const Color surfaceDark = Color(0xFF3F403A);

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F0); // 부드러운 화이트
  static const Color textSecondary = Color(0xFFD4D4C8);
  static const Color textTertiary = Color(0xFFA3A399);
  static const Color textOnAccent = Color(0xFF2A2B26);

  // Accent Colors (따뜻한 계열)
  static const Color accentWarm = Color(0xFFE8B17F); // 따뜻한 베이지
  static const Color accentPeach = Color(0xFFEFAD7A); // 복숭아색
  static const Color accentTerracotta = Color(0xFFCB7E5C); // 테라코타
  static const Color accentCream = Color(0xFFF2E8DC); // 크림색

  // Mood Colors (감정 표현용)
  static const Color moodJoy = Color(0xFFFFC857); // 따뜻한 노랑
  static const Color moodCalm = Color(0xFFA8D5BA); // 편안한 민트
  static const Color moodEnergetic = Color(0xFFFF8552); // 활기찬 오렌지
  static const Color moodPeaceful = Color(0xFFC9B8A3); // 평온한 모카
  static const Color moodSad = Color(0xFF8E9AAF); // 차분한 블루그레이

  // Functional Colors
  static const Color success = Color(0xFF8FAF7F);
  static const Color warning = Color(0xFFE8B17F);
  static const Color error = Color(0xFFD47264);
  static const Color info = Color(0xFF9EADB8);

  // Shadow Colors
  static const Color shadow = Color(0x40000000);
  static const Color shadowLight = Color(0x20000000);

  // Gradient Colors (따뜻한 그라데이션)
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFD99058), Color(0xFFE8B17F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF3B3C35), Color(0xFF4A4B43)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF8552), Color(0xFFD99058), Color(0xFFE8B17F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity Variants
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  static Color backgroundWithOpacity(double opacity) =>
      background.withOpacity(opacity);

  static Color surfaceWithOpacity(double opacity) =>
      surface.withOpacity(opacity);
}
