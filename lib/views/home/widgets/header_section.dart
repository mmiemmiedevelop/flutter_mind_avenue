import 'package:flutter/material.dart';
import 'package:moodavenue/widgets/icon_badge.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

/// 홈 화면 상단 헤더 섹션
///
/// 사용자 인사말, 현재 날짜, 캘린더 및 설정 아이콘을 표시합니다.
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekday = weekdays[now.weekday - 1];
    final formattedDate = '${now.year}년 ${now.month}월 ${now.day}일 $weekday';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('안녕하세요!', style: AppTextStyles.heading1),
                  const Text('heylin님✋🏻', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(formattedDate, style: AppTextStyles.heading3),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                IconBadge(
                  icon: Icons.calendar_today_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/calendar'),
                ),
                const SizedBox(width: 8),
                IconBadge(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

