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
              title: '오늘의 한마디',
              quote: '잠시 후 다시 시도해 주세요.',
              author: null,
              onRefresh: _reloadQuote,
            );
          }

          final quote = snapshot.data;
          if (quote == null) {
            return _QuoteContent(
              title: '오늘의 한마디',
              quote: '준비된 문장이 없어요.\n기분을 조금 더 기록해볼까요?',
              author: null,
              onRefresh: _reloadQuote,
            );
          }

          return _QuoteContent(
            title: '오늘의 한마디',
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                onPressed: onRefresh,
                tooltip: '새로고침',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: AppTextStyles.body18Medium.copyWith(color: AppColors.textPrimary, height: 1.4),
          ),
          if (author != null && author!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '- $author',
              style: AppTextStyles.body14Regular.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
