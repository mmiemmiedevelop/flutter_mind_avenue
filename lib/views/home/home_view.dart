import 'package:flutter/material.dart';
import 'package:moodavenue/widgets/card_container.dart';
import 'package:moodavenue/widgets/icon_badge.dart';
import 'package:moodavenue/views/home/widgets/mood_selector_bar.dart';
import 'package:moodavenue/views/home/widgets/note_input.dart';
import 'package:moodavenue/widgets/ad_placeholder.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- HEADER ---------------------------------------------------
              _HeaderSection(),
              const SizedBox(height: 16),

              // ---- QUOTE ----------------------------------------------------
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '당신을 위한 한마디',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.지금 이 순간 아무것도 해결하지 않아도 괜찮아.\n모든 건 조금씩 괜찮아질 거야.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B6F76),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- MOOD -----------------------------------------------------
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 기분',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const MoodSelectorBar(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- NOTE -----------------------------------------------------
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기록 한마디',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 12),
                    NoteInput(textTheme: textTheme),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- AD -------------------------------------------------------
              const AdPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- HEADER 섹션 -----------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, heylin님✋🏻',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF121417),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '2025년 9월 12일 금요일',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8D939C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                const IconBadge(icon: Icons.calendar_today_outlined),
                const SizedBox(width: 8),
                const IconBadge(icon: Icons.sunny),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
