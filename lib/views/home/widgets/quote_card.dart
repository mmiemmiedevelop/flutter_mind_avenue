import 'package:flutter/material.dart';
import 'package:moodavenue/services/firebase.dart';
import 'package:moodavenue/models/quote.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 감성적인 인용구를 표시하는 카드 위젯
class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  late Future<Quote?> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = _loadQuote();
  }

  Future<Quote?> _loadQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final savedDate = prefs.getString('quote_date');
    final savedQuoteText = prefs.getString('quote_text');
    final savedQuoteAuthor = prefs.getString('quote_author');
    final savedQuoteMoodLevel = prefs.getInt('quote_mood_level');

    // 저장된 날짜가 오늘과 같고 저장된 인용구가 있으면 캐시 사용
    if (savedDate == today &&
        savedQuoteText != null &&
        savedQuoteMoodLevel != null) {
      return Quote(
        id: 'cached',
        moodLevel: savedQuoteMoodLevel,
        text: savedQuoteText,
        author: savedQuoteAuthor ?? '',
      );
    }

    // 새로운 인용구 가져오기
    final quote = await FirebaseService().getRandomQuoteByAverageMood(days: 7);

    if (quote != null) {
      // 새로운 인용구 저장
      await prefs.setString('quote_date', today);
      await prefs.setString('quote_text', quote.text);
      await prefs.setString('quote_author', quote.author ?? '');
      await prefs.setInt('quote_mood_level', quote.moodLevel);
    }

    return quote;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<Quote?>(
        future: _quoteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _QuoteContent(
              title: '오늘 한 줄',
              quote: '잠시 후 다시 시도해 주세요.',
              author: null,
            );
          }

          final quote = snapshot.data;
          if (quote == null) {
            return const _QuoteContent(
              title: '오늘 한 줄',
              quote: '준비된 문장이 없어요.\n기분을 조금 더 기록해볼까요?',
              author: null,
            );
          }

          return _QuoteContent(
            title: '오늘 한 줄',
            quote: quote.text,
            author: quote.author,
          );
        },
      ),
    );
  }
}

class _QuoteContent extends StatelessWidget {
  final String title;
  final String quote;
  final String? author;

  const _QuoteContent({required this.title, required this.quote, this.author});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              quote,
              style: AppTextStyles.body16Regular.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${(author != null && author!.trim().isNotEmpty) ? author : 'Mood'}',
                style: AppTextStyles.caption12Regular.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
