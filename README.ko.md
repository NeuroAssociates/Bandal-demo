# BandalDemo

[English](README.md) · [Bandal 라이브러리](https://github.com/NeuroAssociates/Bandal)

**BandalDemo**는 Python [pandas](https://pandas.pydata.org/)를 모델로 한 Swift 표 형식 데이터 분석 패키지 [**Bandal**](https://github.com/NeuroAssociates/Bandal)을 소개하는 macOS SwiftUI 앱입니다. 각 데모는 앱에 포함된 CSV 파일에 실제 Bandal 코드를 실행하고, Swift 소스 코드와 결과 화면을 함께 보여줍니다.

Bandal의 수치 엔진은 [MLX Swift](https://github.com/ml-explore/mlx-swift)로 가속되며, 이 저장소에는 `mlx-swift`가 포함되어 있습니다.

## 주요 기능

사이드바에는 라이브러리의 주요 기능을 다루는 26개의 데모가 있습니다.

- **CSV 및 데이터 확인**: CSV 개요, `head`/`tail`, 요약, CSV 옵션, 테이블 정리
- **결측값 및 파생 열**: 결측값 채우기·삭제, 행 기반 계산 열
- **조회**: 필터링, `RowPredicate`, 표현식 기반 `query(...)`, 문자열 및 날짜 처리
- **그룹화 및 조인**: 지역별 집계, 조인 전략, `melt`, `pivotTable`, rolling/expanding 윈도우
- **통계**: 구조화된 `describe`/`info`, 상관관계 및 공분산, Series 기본, 타입 값
- **내보내기**: JSON 및 Markdown 출력
- **수치 엔진**: MLX 기반 런타임과 실행 정책
- **실무형 시나리오**: 공장 출하, 학생 성적, 터보팬 엔진 상태(CMAPSS), 기계 소리 이상 탐지(MIMII)

각 데모의 Swift 코드는 `BandalDemo/Playground`에, 결과 화면은 `BandalDemo/View/DemoResult`에 있습니다. 앱 UI는 영어와 한국어를 지원합니다.

## 요구 사항

- macOS (프로젝트 대상은 macOS 27.0이며, MLX 가속을 위해 Apple silicon을 권장합니다)
- Metal 툴체인이 설치된 Xcode
- Swift Package 의존성 (Xcode가 자동으로 해결): [Bandal](https://github.com/NeuroAssociates/Bandal), [mlx-swift](https://github.com/ml-explore/mlx-swift), [swift-numerics](https://github.com/apple/swift-numerics)

## 시작하기

1. 저장소를 클론합니다.
2. Xcode에서 `BandalDemo.xcodeproj`를 엽니다.
3. **BandalDemo** 스킴을 선택하고 실행(⌘R)합니다.

## 포함된 데이터

`BandalDemo/Data`의 모든 CSV 파일은 **가상으로 만든 데이터** 또는 **공개된 데이터**입니다. 실제 개인정보, 고객 정보, 기업 기밀은 포함하지 않습니다.

| 파일 | 행 수 | 설명 | 출처 |
| ---- | ----- | ---- | ---- |
| `factory_data.csv` | 40,000 | 철강 제품 출하 기록 | 가상 데이터 (고객, 공장, 규격은 모두 임의로 만든 것) |
| `global_sales_raw.csv` | 9 | 정제 데모를 위해 일부러 지저분하게 만든 국가별 매출 | 가상 데이터 |
| `country_info.csv` | 10 | 국가, 지역, 영업팀 매핑 | 가상 데이터 |
| `cmapss_sample.csv` | 1,000 | 잔여 수명(RUL)이 포함된 터보팬 엔진 센서 측정값 | 공개 NASA C-MAPSS 데이터셋의 일부, [Kaggle](https://www.kaggle.com)에서 받음 |
| `mimii_sample.csv` | 800 | 정상/이상 기계 소리의 음향 특징(RMS, 스펙트럼 중심, 영교차율) | 공개 MIMII 데이터셋의 일부, [Kaggle](https://www.kaggle.com)에서 받음 |

CMAPSS와 MIMII 파일은 Kaggle에서 받은 데이터셋의 **일부분일 뿐**이며, 데모를 위해 샘플링하거나 일부 열·특징만 사용했을 수 있습니다. 완전하거나 공식적인 사본이 아닙니다. 해당 데이터셋의 권리는 원저작자에게 있으며 원래의 라이선스와 이용 약관이 적용됩니다. 다른 용도로 사용하려면 원 출처에서 전체 데이터를 받고 약관을 확인하세요.

## 만든 사람

- [Ned Park](https://africastart.com) of Neuro Associates

## 라이선스

이 프로젝트의 소스 코드는 [MIT](LICENSE) 라이선스를 따릅니다. 포함된 서드파티 데이터셋(CMAPSS, MIMII)에는 이 라이선스가 적용되지 않습니다.
