import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moodavenue/theme/app_colors.dart';

/// ---- AD 배너 (Adaptive) -------------------------------------------------------
/// 화면 너비에 자동으로 맞춰지는 Adaptive 배너 광고
class AdPlaceholder extends StatefulWidget {
  const AdPlaceholder({super.key});

  @override
  State<AdPlaceholder> createState() => _AdPlaceholderState();
}

class _AdPlaceholderState extends State<AdPlaceholder> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // .env 파일에서 광고 ID 가져오기
  String get _adUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_ID_ANDROID'] ??
          'ca-app-pub-3940256099942544/6300978111'; // 테스트 ID (fallback)
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_ID_IOS'] ??
          'ca-app-pub-3940256099942544/2934735716'; // 테스트 ID (fallback)
    }
    return '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    // 화면 너비에 맞는 Adaptive 배너 사이즈
    final width = MediaQuery.of(context).size.width.toInt();
    final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );

    if (adSize == null) {
      debugPrint('❌ Adaptive 배너 사이즈를 가져올 수 없습니다.');
      return;
    }

    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ 광고 로드 성공! 사이즈: ${adSize.width}x${adSize.height}');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ 광고 로드 실패: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 광고가 로드되지 않았으면 플레이스홀더 표시
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        width: double.infinity,
        height: 50, // Adaptive 배너는 보통 50 정도
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: const Center(
          child: Text(
            '광고 로딩 중...',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ),
      );
    }

    // 광고가 로드되었으면 광고 표시
    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
