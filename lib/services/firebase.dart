import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/mood_record.dart';
import '../models/quote.dart';

/// Firebase Firestore 서비스
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  static const String _userIdKey = 'user_id';
  String? _cachedUserId;

  // ========== 사용자 관리 ==========

  /// 사용자 ID 가져오기 (없으면 새로 생성)
  Future<String> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId!;

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      // 새 사용자 생성
      userId = _uuid.v4();
      await prefs.setString(_userIdKey, userId);

      // Firestore에 사용자 문서 생성
      await _firestore.collection('users').doc(userId).set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // 기존 사용자 - 마지막 접속 시간 업데이트
      await _firestore.collection('users').doc(userId).update({
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    }

    _cachedUserId = userId;
    return userId;
  }

  /// 사용자 ID 초기화 (테스트용)
  Future<void> resetUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    _cachedUserId = null;
  }

  // ========== 기분 기록 관리 ==========

  /// 오늘 기분 기록하기
  /// [moodLevel]: 1=매우좋음, 2=좋음, 3=보통, 4=나쁨, 5=매우나쁨
  Future<void> saveTodayMood({required int moodLevel, String? note}) async {
    if (moodLevel < 1 || moodLevel > 5) {
      throw ArgumentError('기분 레벨은 1-5 사이여야 합니다.');
    }

    final userId = await getUserId();
    final today = DateTime.now();
    final dateId = DateFormat('yyyy-MM-dd').format(today);

    final moodRecord = MoodRecord(
      id: dateId,
      date: DateTime(today.year, today.month, today.day),
      moodLevel: moodLevel,
      note: note,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .doc(dateId)
        .set(moodRecord.toFirestore());
  }

  // /// 특정 날짜 기분 기록하기
  // /// [moodLevel]: 1=매우좋음, 2=좋음, 3=보통, 4=나쁨, 5=매우나쁨
  // Future<void> saveMood({
  //   required DateTime date,
  //   required int moodLevel,
  //   String? note,
  // }) async {
  //   if (moodLevel < 1 || moodLevel > 5) {
  //     throw ArgumentError('기분 레벨은 1-5 사이여야 합니다.');
  //   }

  //   final userId = await getUserId();
  //   final dateId = DateFormat('yyyy-MM-dd').format(date);

  //   final moodRecord = MoodRecord(
  //     id: dateId,
  //     date: DateTime(date.year, date.month, date.day),
  //     moodLevel: moodLevel,
  //     note: note,
  //     createdAt: DateTime.now(),
  //   );

  //   await _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('mood_records')
  //       .doc(dateId)
  //       .set(moodRecord.toFirestore());
  // }

  // /// 오늘 기분 기록 가져오기
  // Future<MoodRecord?> getTodayMood() async {
  //   final today = DateTime.now();
  //   return getMoodByDate(today);
  // }

  /// 특정 날짜 기분 기록 가져오기
  Future<MoodRecord?> getMoodByDate(DateTime date) async {
    final userId = await getUserId();
    final dateId = DateFormat('yyyy-MM-dd').format(date);

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .doc(dateId)
        .get();

    if (!doc.exists) return null;
    return MoodRecord.fromFirestore(doc);
  }

  /// 특정 기간 기분 기록 가져오기
  Future<List<MoodRecord>> getMoodsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = await getUserId();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => MoodRecord.fromFirestore(doc)).toList();
  }

  /// 최근 N개 기분 기록 가져오기
  Future<List<MoodRecord>> getRecentMoods({int limit = 30}) async {
    final userId = await getUserId();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => MoodRecord.fromFirestore(doc)).toList();
  }

  /// 모든 기분 기록 가져오기
  Future<List<MoodRecord>> getAllMoods() async {
    final userId = await getUserId();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => MoodRecord.fromFirestore(doc)).toList();
  }

  // /// 기분 기록 스트림 (실시간 업데이트)
  // Stream<List<MoodRecord>> getMoodsStream() async* {
  //   final userId = await getUserId();

  //   yield* _firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('mood_records')
  //       .orderBy('date', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => MoodRecord.fromFirestore(doc))
  //             .toList(),
  //       );
  // }

  /// 기분 기록 삭제
  Future<void> deleteMood(DateTime date) async {
    final userId = await getUserId();
    final dateId = DateFormat('yyyy-MM-dd').format(date);

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_records')
        .doc(dateId)
        .delete();
  }

  // ========== 기분 평균 계산 ==========

  /// 최근 N일 기분 평균 계산
  Future<double> getAverageMood({int days = 7}) async {
    final moods = await getRecentMoods(limit: days);
    if (moods.isEmpty) return 3.0; // 기본값

    final sum = moods.fold<int>(0, (sum, mood) => sum + mood.moodLevel);
    return sum / moods.length;
  }

  /// 전체 기분 평균 계산
  Future<double> getOverallAverageMood() async {
    final moods = await getAllMoods();
    if (moods.isEmpty) return 3.0; // 기본값

    final sum = moods.fold<int>(0, (sum, mood) => sum + mood.moodLevel);
    return sum / moods.length;
  }

  // ========== 명언 관리 ==========

  /// 명언 추가 (관리자용)
  /// [moodLevel]: 1=매우좋음, 2=좋음, 3=보통, 4=나쁨, 5=매우나쁨
  Future<void> addQuote({
    required int moodLevel,
    required String text,
    String? author,
  }) async {
    if (moodLevel < 1 || moodLevel > 5) {
      throw ArgumentError('기분 레벨은 1-5 사이여야 합니다.');
    }

    final quote = Quote(
      id: '',
      moodLevel: moodLevel,
      text: text,
      author: author,
    );

    await _firestore.collection('quotes').add(quote.toFirestore());
  }

  /// 특정 기분 레벨의 명언 가져오기
  Future<List<Quote>> getQuotesByMoodLevel(int moodLevel) async {
    if (moodLevel < 1 || moodLevel > 5) {
      throw ArgumentError('기분 레벨은 1-5 사이여야 합니다.');
    }

    final snapshot = await _firestore
        .collection('quotes')
        .where('moodLevel', isEqualTo: moodLevel)
        .get();

    return snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList();
  }

  /// 기분 평균에 맞는 랜덤 명언 가져오기
  Future<Quote?> getRandomQuoteByAverageMood({int days = 7}) async {
    final averageMood = await getAverageMood(days: days);
    final roundedMood = averageMood.round().clamp(1, 5);

    final quotes = await getQuotesByMoodLevel(roundedMood);
    if (quotes.isEmpty) return null;

    // 랜덤으로 하나 선택
    quotes.shuffle();
    return quotes.first;
  }

  /// 특정 기분 레벨의 랜덤 명언 가져오기
  Future<Quote?> getRandomQuote(int moodLevel) async {
    final quotes = await getQuotesByMoodLevel(moodLevel);
    if (quotes.isEmpty) return null;

    quotes.shuffle();
    return quotes.first;
  }

  // /// 모든 명언 가져오기
  // Future<List<Quote>> getAllQuotes() async {
  //   final snapshot = await _firestore
  //       .collection('quotes')
  //       .orderBy('moodLevel')
  //       .get();

  //   return snapshot.docs.map((doc) => Quote.fromFirestore(doc)).toList();
  // }

  // /// 명언 삭제 (관리자용)
  // Future<void> deleteQuote(String quoteId) async {
  //   await _firestore.collection('quotes').doc(quoteId).delete();
  // }

  // ========== 초기 데이터 세팅 ==========

  /// 샘플 명언 데이터 추가 (최초 1회만 실행)
  // Future<void> initializeSampleQuotes() async {
  //   final quotes = await getAllQuotes();
  //   if (quotes.isNotEmpty) return; // 이미 데이터가 있으면 건너뛰기

  //   final sampleQuotes = [
  //     // 기분 레벨 1 - 매우 좋음
  //     {'moodLevel': 1, 'text': '오늘의 당신은 누구보다 빛나고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 기세라면 무엇이든 해낼 수 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘 당신의 에너지는 주변까지 밝게 만들어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 미소가 하루 전체를 바꿔요.', 'author': null},
  //     {'moodLevel': 1, 'text': '자신 있게 나아가세요, 지금 완벽해요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 당신은 최고의 버전이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '뭐든 시작해도 다 잘 될 기운이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 당신이 주인공인 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 흐름 그대로, 쭉 가면 됩니다.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 기분이면 산도 옮길 수 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 열정이 세상을 움직여요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 당신은 놀라울 만큼 강해요.', 'author': null},
  //     {'moodLevel': 1, 'text': '어떤 목표도 오늘의 당신 앞에선 작아요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 시도하는 것마다 기분 좋게 열릴 거예요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 에너지는 누구도 막을 수 없어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 활력이 당신을 더 좋은 곳으로 이끌어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 자신감이 가장 큰 힘이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 성장하기 완벽한 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 당신은 정말 아름답고 멋져요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 발걸음은 오늘도 힘차요.', 'author': null},
  //     {'moodLevel': 1, 'text': '기쁨이 당신을 밀어주고 있어요.', 'author': null},
  //     {
  //       'moodLevel': 1,
  //       'text': '오늘의 당신은 어떤 어려움도 웃으며 이겨낼 수 있어요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 1, 'text': '이 기분 그대로 세상을 채워보세요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 빛이 멀리까지 뻗어나가고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 당신을 위한 축복 같은 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '새로운 기회가 당신을 기다리고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 기분은 최고의 선물이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 긍정이 멋진 일들을 끌어와요.', 'author': null},
  //     {'moodLevel': 1, 'text': '기분 좋은 하루는 기분 좋은 결과를 만들어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 당신의 시간, 마음껏 누리세요.', 'author': null},
  //     {'moodLevel': 1, 'text': '이 에너지가 당신을 높은 곳으로 올릴 거예요.', 'author': null},
  //     {'moodLevel': 1, 'text': '끝없이 올라갈 수 있는 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 설렘을 믿어도 좋아요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 당신은 믿을 만한 사람, 믿을 만한 힘이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '모두가 당신 같은 에너지를 원할 거예요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘 당신은 정말 멋진 흐름 속에 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 가능성은 지금 가장 반짝이고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 멀리 가도 괜찮은 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 열정이 주변에 전해지고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 기운은 특별하니까 마음껏 사용하세요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신의 노력과 에너지가 완벽히 조화를 이루고 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 당신의 이야기가 더 강해지는 날이에요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 기분은 당신을 더 멋지게 만들어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘의 당신은 그 어떤 불안도 이겨낼 수 있어요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신이 가진 힘을 마음껏 펼쳐보세요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘은 모든 길이 당신 쪽으로 열릴 거예요.', 'author': null},
  //     {'moodLevel': 1, 'text': '당신은 오늘도 자신만의 방식으로 빛나요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 행복이 앞으로의 행복을 끌어와요.', 'author': null},
  //     {'moodLevel': 1, 'text': '오늘 당신은 \'잘하고 있는 사람\' 그 자체예요.', 'author': null},
  //     {'moodLevel': 1, 'text': '지금의 당신은 그 무엇보다 강하고 선명해요.', 'author': null},

  //     // 기분 레벨 2 - 좋음
  //     {'moodLevel': 2, 'text': '오늘의 편안함을 천천히 음미해보세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금 이 순간이 가장 소중해요.', 'author': null},
  //     {'moodLevel': 2, 'text': '건강을 챙기는 작은 습관이 큰 행복을 만들어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금은 숨을 고르고 가기 좋은 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 평온함을 오래 간직하세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금도 충분히 잘하고 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 몸과 마음을 돌보기 딱 좋은 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '자연스럽게 흐르는 하루를 받아들이세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 상태가 아주 좋아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '천천히, 하지만 확실하게 나아가고 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 햇살처럼 따뜻하게 자신을 돌보세요.', 'author': null},
  //     {
  //       'moodLevel': 2,
  //       'text': '내 몸이 필요로 하는 걸 들어주는 하루가 되길 바라요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 2, 'text': '오늘은 심호흡과 함께 시작해보세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 리듬이 아주 안정적이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 마음이 편안해지는 일을 해도 좋아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '일상의 소소한 행복이 당신 곁에 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 당신은 가장 자연스러운 모습이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 기분은 \'괜찮음\' 그 자체예요.', 'author': null},
  //     {'moodLevel': 2, 'text': '당신의 하루가 조용히 빛나고 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘도 자신에게 작은 친절 하나를 선물하세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금 느끼는 안정감은 당신의 힘이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 몸과 마음이 균형을 이루는 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 온도를 잘 유지해보세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 여유는 당신에게 꼭 필요한 순간이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금 느끼는 편안함을 믿어도 좋아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 쉬어 가라는 신호일 수도 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 만족감은 아주 건강해요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 감정은 당신에게 좋은 영향을 주고 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 작은 기쁨을 느끼기 좋은 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 기분이 당신의 몸을 더 편하게 만들어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘 느끼는 평화는 소중한 선물이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '균형 잡힌 하루가 당신 앞에 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 기분을 천천히 음미해보세요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 안정감이 당신을 지탱해요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘 하루는 당신을 위한 휴식 같은 선물이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 평온이 아주 좋아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '여유는 당신의 몸과 마음을 더 건강하게 해요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 모든 게 적당히 괜찮은 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금 있는 그대로의 당신이 충분히 멋져요.', 'author': null},
  //     {'moodLevel': 2, 'text': '단정하고 잔잔한 하루가 당신을 감싸고 있어요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 행복은 부담 없는 행복이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 템포가 딱 좋아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 조용한 만족을 오래 기억하세요.', 'author': null},
  //     {
  //       'moodLevel': 2,
  //       'text': '지금은 너무 빠르지 않게, 너무 느리지 않게 좋은 흐름이에요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 2, 'text': '오늘 느끼는 안정은 내일의 힘이 돼요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 평온은 당신을 지켜주는 보호막이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘은 마음의 숨을 쉬기 좋은 날이에요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금 느껴지는 잔잔함이 정말 귀해요.', 'author': null},
  //     {'moodLevel': 2, 'text': '오늘의 자신을 사랑해줘도 괜찮아요.', 'author': null},
  //     {'moodLevel': 2, 'text': '지금의 순간이 당신에게 딱 맞아요.', 'author': null},

  //     // 기분 레벨 3 - 보통
  //     {'moodLevel': 3, 'text': '오늘은 그냥 그런 날이어도 괜찮아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '인생은 오르락내리락하니까, 지금도 자연스러워요.', 'author': null},
  //     {'moodLevel': 3, 'text': '무탈한 하루도 소중한 하루예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 당신도 충분히 잘하고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '모든 감정이 늘 최고일 필요는 없어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '가끔은 이런 평범함이 안정감을 줘요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신은 적당히 잘 버티고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '특별하지 않아도 괜찮아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 감정은 지나가는 구름일 뿐이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘은 마음이 크게 들뜨지 않아도 괜찮아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금도 충분히 의미 있는 하루예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '이런 날도 있어요. 다 자연스러워요.', 'author': null},
  //     {'moodLevel': 3, 'text': '당신은 그저 당신이면 돼요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘은 마음의 속도가 느린 날일 뿐이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금은 잠시 쉬어가는 시간일 수 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '계속 반짝일 필요는 없어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '그냥 이대로도 괜찮아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신도 분명 나아가고 있는 중이에요.', 'author': null},
  //     {
  //       'moodLevel': 3,
  //       'text': '지금의 당신은 평온과 고민 사이 어딘가에 있겠죠. 그곳도 나쁘지 않아요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 3, 'text': '오늘도 당신은 충분히 가치 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '감정의 평균도 삶의 일부예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신은 \'괜찮은 사람\' 그 자체예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '완벽하지 않아도 좋아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 느낌은 자연스러운 삶의 흐름이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신은 조용한 강함을 갖고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '가끔은 머릿속이 조용한 것도 괜찮아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '평범한 하루가 주는 안정도 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 감정은 괜찮음으로 향하는 중간단계예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 감정이 전부는 아니에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 당신도 충분히 멋져요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘은 큰 감정보다 작은 감정들이 더 많을 뿐이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '당신은 잘 버티고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '그냥 그런 날도 다 의미 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 적당함은 당신을 지켜줘요.', 'author': null},
  //     {'moodLevel': 3, 'text': '모든 날이 특별할 순 없어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '적당한 하루는 오히려 당신을 안정시켜줘요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 당신은 잠시 머무는 중이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '가끔은 아무 감정도 없는 게 맞아요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 힘은 조용하지만 단단해요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 나도 괜찮다, 그걸로 충분해요.', 'author': null},
  //     {'moodLevel': 3, 'text': '감정은 파도처럼 오가요. 지금은 잔잔할 뿐이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신은 평범해서 아름다워요.', 'author': null},
  //     {'moodLevel': 3, 'text': '완만한 하루가 더 많은 걸 채워줘요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 당신도 충분히 살아가고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘은 무리하지 말아도 돼요.', 'author': null},
  //     {'moodLevel': 3, 'text': '당신은 지금도 성장 중이에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 기분은 내일의 기분과 다를 거예요.', 'author': null},
  //     {'moodLevel': 3, 'text': '지금의 상태가 나쁜 건 아니에요.', 'author': null},
  //     {'moodLevel': 3, 'text': '오늘의 당신도 값진 하루를 살고 있어요.', 'author': null},
  //     {'moodLevel': 3, 'text': '평범한 날이 쌓여 특별한 삶이 돼요.', 'author': null},

  //     // 기분 레벨 4 - 나쁨
  //     {'moodLevel': 4, 'text': '오늘은 조금 힘들어도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '마음이 무거운 날엔 잠시 쉬어가도 돼요.', 'author': null},
  //     {'moodLevel': 4, 'text': '긴장을 내려놓아도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신은 지금 잘 버티는 중이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '잠시 기대도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 스스로에게 더 따뜻하게 대해주세요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금의 감정도 지나갈 거예요.', 'author': null},
  //     {'moodLevel': 4, 'text': '천천히, 아주 천천히 숨 고르세요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 무리하지 않아도 돼요.', 'author': null},
  //     {'moodLevel': 4, 'text': '힘든 마음도 당신의 일부일 뿐이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금 충분히 애쓰고 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '울어도 괜찮아요. 진짜예요.', 'author': null},
  //     {'moodLevel': 4, 'text': '마음이 시그널을 보내는 날일 뿐이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 그냥 있어도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신은 여전히 소중한 사람이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금의 감정이 잘못된 건 절대 아니에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘의 당신도 사랑받을 자격이 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '잠시 멈춰도 삶은 계속 흘러가요.', 'author': null},
  //     {'moodLevel': 4, 'text': '혼자 힘으로만 버티지 않아도 돼요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신의 속도가 지금은 느릴 뿐이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘의 무거움은 당신 탓이 아니에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '토닥토닥, 마음을 다독여주세요.', 'author': null},
  //     {
  //       'moodLevel': 4,
  //       'text': '지금의 감정은 당신을 약하게 만드는 게 아니라 깊게 만드는 중이에요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 4, 'text': '조금 무거운 날에도 당신은 가치 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 쉬어도 될 권리가 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금 흔들린다고 해서 당신이 약한 건 아니에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '버티는 것도 큰 용기예요.', 'author': null},
  //     {'moodLevel': 4, 'text': '조급해하지 않아도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신의 마음은 지금 휴식을 원하고 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '모든 감정을 너무 붙잡지 않아도 돼요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘만큼은 편하게 숨 쉬세요.', 'author': null},
  //     {'moodLevel': 4, 'text': '마음이 아픈 건 잘못이 아니에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신에게는 위로받을 자격이 있어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금의 당신은 충분히 용감해요.', 'author': null},
  //     {'moodLevel': 4, 'text': '아무것도 하지 않는 시간도 필요해요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 그저 \'버티는 하루\'여도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금의 감정이 당신을 약하게 하지 않아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신의 마음이 힘든 건 자연스러운 일이에요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘은 스스로를 지켜주는 하루로 남겨주세요.', 'author': null},
  //     {'moodLevel': 4, 'text': '괜찮아지려고 애쓰지 않아도 돼요.', 'author': null},
  //     {'moodLevel': 4, 'text': '머릿속이 무겁다면 내려놓아도 좋아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신의 마음은 쉬는 것도 일종의 치유예요.', 'author': null},
  //     {'moodLevel': 4, 'text': '힘든 하루도 언젠가는 가벼워져요.', 'author': null},
  //     {'moodLevel': 4, 'text': '지금은 멈춰 있어도 괜찮아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '오늘 당신은 충분히 애썼어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '스스로를 너무 몰아붙이지 말아요.', 'author': null},
  //     {'moodLevel': 4, 'text': '당신이 느끼는 걸 누구도 함부로 말할 수 없어요.', 'author': null},
  //     {'moodLevel': 4, 'text': '마음이 아파도 당신의 가치는 그대로예요.', 'author': null},
  //     {'moodLevel': 4, 'text': '숨 쉬는 것만으로도 용기예요.', 'author': null},
  //     {
  //       'moodLevel': 4,
  //       'text': '오늘의 무거움은 당신을 더 깊고 단단하게 만들 거예요.',
  //       'author': null,
  //     },

  //     // 기분 레벨 5 - 매우 나쁨
  //     {
  //       'moodLevel': 5,
  //       'text': '지금 너무 힘들어도, 그건 절대 당신 잘못이 아니에요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 5, 'text': '당신 편은 여전히 여기 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금 느끼는 고통이 당신의 가치를 줄이지 않아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '오늘 버티는 것만으로도 정말 큰 용기예요.', 'author': null},
  //     {'moodLevel': 5, 'text': '많이 힘들었죠. 그 마음 이해해요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 감정은 당신이 잘못해서 생기는 게 아니에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '누구나 무너질 때가 있어요. 당신도 괜찮아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금은 그냥 살아있는 것만으로도 잘하고 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신이 느끼는 아픔은 진짜예요. 존중받아야 해요.', 'author': null},
  //     {'moodLevel': 5, 'text': '혼자가 아니에요. 정말로.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금처럼 힘든 날은 오래 머물지 않아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '이 감정도 언젠가는 지나가요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 포기하지 않는 사람이라는 걸 알고 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금 힘든 당신조차 사랑받을 가치가 있어요.', 'author': null},
  //     {
  //       'moodLevel': 5,
  //       'text': '슬퍼도 괜찮아요. 약해서가 아니라 사람이기 때문이에요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 5, 'text': '울어도 괜찮아요. 그건 잘못이 아니에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 지금 필요한 만큼 힘내고 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '무너져도 다시 일어낼 힘이 있는 사람이에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 어둠 속에도 당신의 빛은 사라지지 않았어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '오늘의 아픔이 당신의 미래를 결정하지 않아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신에게는 다시 웃을 날이 와요.', 'author': null},
  //     {
  //       'moodLevel': 5,
  //       'text': '지금의 감정은 당신을 괴롭히지만, 당신을 정의하지 않아요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 5, 'text': '너무 아파서 멈춰도 괜찮아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금은 쉬는 것도 살아가는 일이에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 다시 일어날 수 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금은 바닥 같아도 올라갈 곳이 남아 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신이 얼마나 애쓰고 버텼는지 알고 싶어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '힘든 시간을 지나고 있는 당신을 안아주고 싶어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '잘해왔고, 지금도 잘하고 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 고통은 당신의 잘못이 절대 아니에요.', 'author': null},
  //     {
  //       'moodLevel': 5,
  //       'text': '절망 속에서도 당신은 살아 있어요. 그것만으로 충분해요.',
  //       'author': null,
  //     },
  //     {'moodLevel': 5, 'text': '오늘의 눈물은 내일의 당신을 치유할 거예요.', 'author': null},
  //     {'moodLevel': 5, 'text': '이 상황에서도 당신은 혼자가 아니에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 마음을 부정하지 않아도 돼요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신의 감정을 이해하려는 사람은 반드시 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '너무 힘들다면 도움을 구해도 괜찮아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 여기까지 버텼어요. 그건 대단한 일이에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '모든 잘못을 자신에게 돌릴 필요 없어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신의 존재만으로도 소중해요.', 'author': null},
  //     {'moodLevel': 5, 'text': '오늘은 잠시 기대도 괜찮아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 짙은 어둠도 조금씩 옅어질 거예요.', 'author': null},
  //     {'moodLevel': 5, 'text': '회복은 천천히 와도 괜찮아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 당신을 미워하지 말아요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신에게는 다시 빛날 날이 남아 있어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '오늘 버틴 당신에게 정말 고맙다고 말해주고 싶어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '모든 감정을 다 안고 있을 필요 없어요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 결코 실패한 사람이 아니에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금 겪는 고통은 당신의 탓이 아니에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '당신은 사랑받을 가치가 있는 사람이에요.', 'author': null},
  //     {'moodLevel': 5, 'text': '지금의 당신 그대로 괜찮아요. 정말로.', 'author': null},
  //   ];

  //   for (final quote in sampleQuotes) {
  //     await addQuote(
  //       moodLevel: quote['moodLevel'] as int,
  //       text: quote['text'] as String,
  //       author: quote['author'] as String?,
  //     );
  //   }
  // }
}
