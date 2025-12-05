import 'package:cloud_firestore/cloud_firestore.dart';

/// 명언 모델
class Quote {
  final String id;
  final int moodLevel; // 1=매우좋음, 2=좋음, 3=보통, 4=나쁨, 5=매우나쁨
  final String text;
  final String? author;

  Quote({
    required this.id,
    required this.moodLevel,
    required this.text,
    this.author,
  });

  /// Firestore 문서를 Quote 객체로 변환
  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quote(
      id: doc.id,
      moodLevel: data['moodLevel'] as int,
      text: data['text'] as String,
      author: data['author'] as String?,
    );
  }

  /// Quote 객체를 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {'moodLevel': moodLevel, 'text': text, 'author': author};
  }
}
