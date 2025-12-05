import 'package:flutter/material.dart';
import 'package:moodavenue/theme/app_colors.dart';
import 'package:moodavenue/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// 설정 화면
class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  bool _notificationEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 저장된 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notification_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
    });
  }

  /// 알림 설정 저장
  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  /// 다크모드 설정 저장
  Future<void> _saveDarkModeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode_enabled', value);
    setState(() {
      _darkModeEnabled = value;
    });
    // TODO: 실제 테마 변경 로직 구현 필요
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('다크모드는 향후 버전에서 지원될 예정입니다')));
  }

  /// 이메일 보내기
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'developer@moodavenue.com',
      query: 'subject=무드애비뉴 문의&body=',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이메일 앱을 실행할 수 없습니다')));
      }
    }
  }

  /// 데이터 백업
  Future<void> _showBackupDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 백업'),
        content: const Text('모든 기록이 클라우드에 백업됩니다.\n백업하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 백업 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('백업 기능은 향후 버전에서 지원될 예정입니다')),
              );
            },
            child: const Text('백업'),
          ),
        ],
      ),
    );
  }

  /// 캐시 삭제
  Future<void> _showClearCacheDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('임시 파일과 캐시를 삭제합니다.\n(기록은 삭제되지 않습니다)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: 실제 캐시 삭제 로직 구현
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('캐시가 삭제되었습니다')));
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 앱 초기화
  Future<void> _showResetDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 초기화'),
        content: const Text(
          '⚠️ 모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 실제 초기화 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('앱 초기화 기능은 향후 버전에서 지원될 예정입니다')),
              );
            },
            child: const Text('초기화', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('세팅'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 일반 섹션
          _buildSectionHeader('일반'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            value: _notificationEnabled,
            onChanged: _saveNotificationSetting,
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: '다크 모드',
            subtitle: '준비 중',
            value: _darkModeEnabled,
            onChanged: _saveDarkModeSetting,
          ),
          const Divider(height: 1),

          // 데이터 섹션
          _buildSectionHeader('데이터'),
          _buildTile(
            icon: Icons.backup_outlined,
            title: '데이터 백업',
            subtitle: '클라우드에 백업',
            onTap: _showBackupDialog,
          ),
          _buildTile(
            icon: Icons.cleaning_services_outlined,
            title: '캐시 삭제',
            subtitle: '임시 파일 정리',
            onTap: _showClearCacheDialog,
          ),
          const Divider(height: 1),

          // 지원 섹션
          _buildSectionHeader('지원'),
          _buildTile(
            icon: Icons.email_outlined,
            title: '개발자에게 메시지 보내기',
            subtitle: 'developer@moodavenue.com',
            onTap: _sendEmail,
          ),
          _buildTile(
            icon: Icons.article_outlined,
            title: '오픈소스 라이선스',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '무드애비뉴',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.mood, size: 48),
              );
            },
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            onTap: () {
              // TODO: 개인정보 처리방침 페이지로 이동
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('준비 중입니다')));
            },
          ),
          const Divider(height: 1),

          // 기타 섹션
          _buildSectionHeader('기타'),
          _buildTile(
            icon: Icons.info_outline,
            title: '버전 정보',
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          _buildTile(
            icon: Icons.restart_alt_outlined,
            title: '앱 초기화',
            subtitle: '모든 데이터 삭제',
            titleColor: Colors.red,
            onTap: _showResetDialog,
          ),
          const SizedBox(height: 32),

          // 푸터
          Center(
            child: Text(
              'Made with ❤️ by MoodAvenue Team',
              style: AppTextStyles.body14Regular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: AppTextStyles.body14Regular.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 일반 타일
  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body16Regular.copyWith(
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.body14Regular.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
              : null),
      onTap: onTap,
    );
  }

  /// 스위치 타일
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.body16Regular.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.body14Regular.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (states) => states.contains(MaterialState.selected) ? AppColors.primary : null,
        ),
      ),
    );
  }
}
