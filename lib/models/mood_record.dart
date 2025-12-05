import 'package:cloud_firestore/cloud_firestore.dart';

/// 기분 기록 모델
class MoodRecord {
  final String id; // 날짜 형식: YYYY-MM-DD
  final DateTime date;
  final int moodLevel; // 1=매우좋음, 2=좋음, 3=보통, 4=나쁨, 5=매우나쁨
  final String? note;
  final DateTime createdAt;

  MoodRecord({
    required this.id,
    required this.date,
    required this.moodLevel,
    this.note,
    required this.createdAt,
  });

  /// Firestore 문서를 MoodRecord 객체로 변환
  factory MoodRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodRecord(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      moodLevel: data['moodLevel'] as int,
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// MoodRecord 객체를 Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'moodLevel': moodLevel,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 복사본 생성
  MoodRecord copyWith({
    String? id,
    DateTime? date,
    int? moodLevel,
    String? note,
    DateTime? createdAt,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
