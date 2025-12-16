# 🔒 보안 가이드

## 민감한 정보 관리

이 프로젝트를 GitHub 등 공개 저장소에 올릴 때는 다음 파일들의 민감한 정보를 제거해야 합니다.

### 1. AdMob 정보

**현재 하드코딩된 위치:**
- `android/app/src/main/AndroidManifest.xml` - AdMob App ID
- `ios/Runner/Info.plist` - AdMob App ID  
- `lib/widgets/ad_placeholder.dart` - 광고 단위 ID

**해결 방법:**

#### 옵션 A: 테스트 ID로 교체 (권장)
개발/오픈소스용으로는 Google의 공식 테스트 ID를 사용하세요:

```
앱 ID: 
- Android: ca-app-pub-3940256099942544~3347511713
- iOS: ca-app-pub-3940256099942544~1458002511

배너 광고 ID:
- Android: ca-app-pub-3940256099942544/6300978111
- iOS: ca-app-pub-3940256099942544/2934735716
```

#### 옵션 B: 환경 변수 사용
1. `.env` 파일 생성 (절대 커밋하지 말 것!)
2. `flutter_dotenv` 패키지 사용
3. `.env.example` 파일만 커밋

### 2. Firebase 정보

**이미 .gitignore에 포함됨 ✅**
- `android/app/google-services.json`
- `lib/firebase_options.dart`

**주의:** 이 파일들이 실수로 커밋되지 않았는지 확인하세요:

```bash
git rm --cached android/app/google-services.json
git rm --cached lib/firebase_options.dart
```

### 3. 서명 키 정보

**이미 .gitignore에 포함됨 ✅**
- `*.keystore`
- `*.jks`
- `key.properties`

### Git 히스토리에서 민감 정보 제거

만약 이미 커밋한 경우:

```bash
# 1. git-filter-repo 설치
brew install git-filter-repo

# 2. 민감한 파일 히스토리에서 제거
git filter-repo --path android/app/google-services.json --invert-paths
git filter-repo --path lib/firebase_options.dart --invert-paths

# 3. 강제 푸시 (주의!)
git push origin --force --all
```

### 체크리스트

공개하기 전 확인사항:

- [ ] AdMob ID를 테스트 ID로 교체했는가?
- [ ] `google-services.json`이 .gitignore에 있는가?
- [ ] `firebase_options.dart`가 .gitignore에 있는가?
- [ ] `.env` 파일이 .gitignore에 있는가?
- [ ] Git 히스토리에 민감 정보가 없는가?
- [ ] README에 환경 설정 방법을 문서화했는가?

### 참고 자료

- [Google AdMob 테스트 광고](https://developers.google.com/admob/android/test-ads)
- [Firebase 보안 규칙](https://firebase.google.com/docs/rules)
- [Git Secrets 제거 가이드](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

