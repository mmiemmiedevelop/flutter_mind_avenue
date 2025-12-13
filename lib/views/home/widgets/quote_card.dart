import 'package:flutter/material.dart';
import 'package:moodavenue/services/firebase.dart';
import 'package:moodavenue/models/quote.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';

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
    _quoteFuture = FirebaseService().getRandomQuoteByAverageMood(days: 7);
  }

  void _reloadQuote() {
    setState(() {
      _quoteFuture = FirebaseService().getRandomQuoteByAverageMood(days: 7);
    });
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
            return _QuoteContent(
              title: '오늘 한 줄',
              quote: '잠시 후 다시 시도해 주세요.',
              author: null,
              onRefresh: _reloadQuote,
            );
          }

          final quote = snapshot.data;
          if (quote == null) {
            return _QuoteContent(
              title: '오늘 한 줄',
              quote: '준비된 문장이 없어요.\n기분을 조금 더 기록해볼까요?',
              author: null,
              onRefresh: _reloadQuote,
            );
          }

          return _QuoteContent(
            title: '오늘 한 줄',
            quote: quote.text,
            author: quote.author,
            onRefresh: _reloadQuote,
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
  final VoidCallback onRefresh;

  const _QuoteContent({
    required this.title,
    required this.quote,
    required this.onRefresh,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onRefresh,
                    tooltip: '새로고침',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
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
