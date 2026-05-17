# YGYG-Poco

오늘 할 수 있을 만큼만, 야금야금.

YGYG-Poco는 해야 할 일을 시작하지 못해 멈춰 있는 사용자를 돕는 AI 실행 보조 애플리케이션 프로토타입입니다. 사용자가 할 일을 두서없이 적거나 과제 사진, 수업 자료를 올리면 AI가 과업을 작고 명확한 행동 단계로 나누고, 지금 바로 시작할 수 있는 순서로 정리해주는 것을 목표로 합니다.

## 문제 인식

설문 결과, 할 일을 처리하는 과정에서 가장 어려운 부분으로 64.7%의 사람들이 "시작하기"를 꼽았습니다. 또한 할 일을 끝마치지 못했을 때 69.6%가 자신에게 실망하거나 무기력함을 느낀다고 답했습니다.

야금야금은 시작 단계의 부담이 실패 경험과 무력감으로 이어질 수 있다는 점에 주목했습니다. 큰 과업을 작은 단위로 쪼개는 청킹 방식을 통해 시작 장벽을 낮추고, 사용자가 한 가지 행동에 바로 몰입할 수 있도록 돕습니다.

## 핵심 기능

- 할 일, 과제 사진, 수업 자료 기반 과업 정리
- AI를 활용한 우선순위 추천
- 바로 실행 가능한 작은 행동 단계 생성
- 과업 목록 저장 및 완료 이력 관리
- 완료 이력을 반영한 개인화 실행 흐름 제공

## 기술 스택

프로토타입 기준 기술 스택입니다.

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Platform**: iOS
- **Development Environment**: Xcode
- **Asset Management**: Assets.xcassets, PNG 이미지 리소스
- **Testing**: XCTest, XCUITest
- **Version Control**: Git, GitHub

## 실행 방법

1. 저장소를 클론합니다.

   ```bash
   git clone https://github.com/Sernn0/YGYG-Poco.git
   cd YGYG-Poco
   ```

2. Xcode에서 프로젝트를 엽니다.

   ```bash
   open Poco.xcodeproj
   ```

3. Xcode 상단에서 `Poco` scheme을 선택하고, 실행 대상을 iPhone Simulator로 설정합니다.

4. `Cmd + R` 또는 Run 버튼을 눌러 앱을 실행합니다.

실제 iPhone 기기에서 실행하려면 Apple Developer Team signing 설정을 각자의 계정으로 변경해야 할 수 있습니다.

## 테스트

이 프로젝트에는 기본 유닛 테스트와 UI 테스트 타깃이 포함되어 있습니다.

- `PocoTests`: 앱 로직 검증을 위한 유닛 테스트 타깃
- `PocoUITests`: 앱 실행 흐름 검증을 위한 UI 테스트 타깃

Xcode에서 테스트를 실행하려면 `Poco` scheme을 선택한 뒤 `Cmd + U`를 누릅니다.

터미널에서 실행할 경우 아래 명령을 사용할 수 있습니다.

```bash
xcodebuild test \
  -project Poco.xcodeproj \
  -scheme Poco \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

사용 중인 Xcode 환경에 `iPhone 16` 시뮬레이터가 없다면, Xcode의 실행 대상 목록에 있는 다른 iPhone Simulator 이름으로 변경하면 됩니다.

## 타겟과 방향

초기 타겟은 과제와 팀플이 많은 대학생입니다. 이후에는 학업 실행 지원을 중심으로 AI 에듀테크 영역까지 확장하는 것을 목표로 합니다.

수익 모델은 무료 체험으로 진입 장벽을 낮추고, 실행 이력 저장과 개인화 AI 기능을 제공하는 프리미엄 모델로 전환을 유도하는 방향을 고려하고 있습니다.
