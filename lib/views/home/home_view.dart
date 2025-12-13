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
    return GestureDetector(
      onTap: () {
        // 화면 터치 시 키보드 포커스 해제
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true, // 키보드가 올라올 때 화면 크기 조정
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- HEADER -------------------------------------------
                const HeaderSection(),
                const SizedBox(height: 20),

                // ---- QUOTE --------------------------------------------
                const SizedBox(height: 180, child: QuoteCard()),
                const SizedBox(height: 15),

                // ---- MOOD ---------------------------------------------
                SizedBox(
                  height: 120,
                  child: CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('오늘의 기분', style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        Expanded(child: Center(child: MoodSelectorBar())),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ---- NOTE ---------------------------------------------
                SizedBox(
                  height: 160,
                  child: CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('기록 한마디', style: AppTextStyles.heading3),
                        const SizedBox(height: 8),
                        const Expanded(child: NoteInput()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ---- AD -----------------------------------------------
                const SizedBox(height: 100, child: AdPlaceholder()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
