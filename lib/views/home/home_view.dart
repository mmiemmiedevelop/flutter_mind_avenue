import 'package:flutter/material.dart';
import 'package:moodavenue/widgets/card_container.dart';
import 'package:moodavenue/views/home/widgets/header_section.dart';
import 'package:moodavenue/views/home/widgets/mood_selector_bar.dart';
import 'package:moodavenue/views/home/widgets/note_input.dart';
import 'package:moodavenue/views/home/widgets/quote_card.dart';
import 'package:moodavenue/widgets/ad_placeholder.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

/// 홈 화면
///
/// 디자인 레퍼런스(첨부 이미지)를 기준으로 다음 섹션으로 구성됩니다.
/// ---- HEADER: 인사말, 날짜, 우측 상단 아이콘들
/// ---- QUOTE: "당신을 위한 한마디" 카드
/// ---- MOOD: "오늘의 기분" 이모지 선택 바
/// ---- NOTE: "기록 한마디" 텍스트 입력 카드
/// ---- AD: 광고 영역(플레이스홀더)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- HEADER (비율 2) -------------------------------------------
              Expanded(flex: 2, child: HeaderSection()),
              const SizedBox(height: 12),

              // ---- QUOTE (비율 3) --------------------------------------------
              Expanded(flex: 3, child: QuoteCard()),
              const SizedBox(height: 12),

              // ---- MOOD (비율 2) ---------------------------------------------
              Expanded(
                flex: 2,
                child: CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('오늘의 기분', style: AppTextStyles.heading3),
                      const SizedBox(height: 12),
                      const MoodSelectorBar(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- NOTE (비율 2) ---------------------------------------------
              Expanded(
                flex: 2,
                child: CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('기록 한마디', style: AppTextStyles.heading3),
                      const SizedBox(height: 12),
                      const Expanded(child: NoteInput()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- AD (비율 2) -----------------------------------------------
              Expanded(flex: 2, child: const AdPlaceholder()),
            ],
          ),
        ),
      ),
    );
  }
}
