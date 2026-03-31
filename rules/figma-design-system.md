# Figma Design System Rules

## MCP Plugin Setup

- **Repo**: `https://github.com/arinspunk/claude-talk-to-figma-mcp.git`
- **위치**: `C:\Users\enjoyworks\claude-talk-to-figma-mcp`
- **빌드**: `bun install && bun run build:win`
- **실행**: 소켓 `bun run socket` (port 3055) → Figma 플러그인에서 채널 연결
- **플러그인 설치**: Figma > Resources > Development > Import from manifest (`src/claude_mcp_plugin/manifest.json`)

## 화면설계 작업 원칙

### 1. 기존 컴포넌트 재사용 (CRITICAL)

절대 수동으로 도형/텍스트를 새로 만들지 마라. 반드시 기존 컴포넌트를 `clone_node`로 복제해서 사용하라.

```
워크플로우: clone_node → insert_child → move_node → 텍스트/속성 수정
```

### 2. 작업 시작 전 분석

새 화면 설계 전 반드시:
1. `get_document_info()`로 문서 구조 파악
2. 기존 화면들의 컴포넌트 ID 수집 (clone 소스용)
3. `get_styled_text_segments()`로 텍스트 스타일 패턴 확인
4. `get_local_components()`로 사용 가능한 컴포넌트 목록 확인

### 3. 화면 배치

- 새 화면은 **(0, 0)** 또는 기존 화면 옆에 배치
- 사용자가 찾기 어려운 위치(10000+ 좌표)에 절대 놓지 마라
- Description 컴포넌트는 메인 프레임 오른쪽 (프레임 너비 + 27px 간격)에 배치

## 디자인 토큰

### 프레임 규격
| 항목 | 값 |
|------|-----|
| iPhone 프레임 | 393 x 852 |
| 배경색 | #FFFFFF |

### 색상 시스템

#### 브랜드 컬러
| 용도 | 색상 | 비고 |
|------|------|------|
| Primary | #2196F3 | 메인 액션, 활성 탭, 링크 |
| Primary Dark | #1976D2 | 버튼 pressed 상태 |
| Primary Light | #BBDEFB | 선택된 항목 배경, 뱃지 배경 |
| Secondary | #607D8B | 보조 아이콘, 비활성 탭 |
| Accent | #FF5722 | 알림 뱃지, 긴급 CTA, 좋아요 |

#### 시맨틱 컬러
| 용도 | 색상 | 사용처 |
|------|------|--------|
| Success | #4CAF50 | 완료, 인증 성공, 온라인 상태 |
| Warning | #FFC107 | 주의, 경고 배너 |
| Error | #F44336 | 입력 에러, 삭제 확인 |
| Info | #2196F3 | 안내 메시지 (Primary와 동일) |

#### 중립 컬러 (Neutral Scale)
| 용도 | 색상 |
|------|------|
| 기본 텍스트 | #212121 |
| 보조 텍스트 | #757575 |
| 비활성/힌트 텍스트 | #BDBDBD |
| 구분선 (Divider) | #E0E0E0 |
| 카드/입력필드 배경 | #F5F5F5 |
| 페이지 배경 | #FAFAFA |
| 순백 배경 | #FFFFFF |

#### Description 전용
| 용도 | 색상 |
|------|------|
| Description 메타 값 | #00C2FF (cyan) |
| Description 배경 | #F2F2F2 |

### 간격 시스템 (4px 기반)

| 토큰 | 값 | 용도 |
|------|-----|------|
| xs | 4px | 아이콘-텍스트 간격, 인라인 요소 |
| sm | 8px | 관련 요소 내부 간격 |
| md | 12px | 리스트 아이템 내부 패딩 |
| base | 16px | 화면 좌우 마진, 섹션 내 요소 간격 |
| lg | 20px | 카드 내부 패딩 |
| xl | 24px | 섹션 간 간격 |
| 2xl | 32px | 주요 섹션 구분 |
| 3xl | 40px | 헤더-본문 간격 |
| 4xl | 48px | 화면 상하 여백 |

### 타이포그래피

#### UI 텍스트 (화면 내)
| 용도 | 폰트 | 크기 | 줄높이 | 색상 |
|------|------|------|--------|------|
| 화면 타이틀 | Roboto Bold | 20px | 28px | #212121 |
| 헤더 타이틀 | Roboto Medium | 17px | 24px | #212121 |
| 섹션 타이틀 | Roboto Bold | 16px | 22px | #212121 |
| 본문 (Body) | Roboto Regular | 15px | 22px | #212121 |
| 보조 텍스트 | Roboto Regular | 13px | 18px | #757575 |
| 캡션/라벨 | Roboto Regular | 12px | 16px | #757575 |
| 버튼 텍스트 | Roboto Medium | 16px | 22px | #FFFFFF |
| 탭바 라벨 | Roboto Medium | 10px | 14px | #757575 |
| 입력필드 힌트 | Roboto Regular | 15px | 22px | #BDBDBD |
| 에러 메시지 | Roboto Regular | 12px | 16px | #F44336 |

#### Description 텍스트 (기존 유지)
| 용도 | 폰트 | 크기 |
|------|------|------|
| Description 라벨 | Noto Sans Bold | 26px |
| Description 메타 값 | Noto Sans Bold | 24px |
| Description 섹션 타이틀 | Roboto Bold | 24px |
| Description 상세 내용 | Roboto Regular | 24px |

### 그림자/엘리베이션

| 레벨 | 값 | 용도 |
|------|-----|------|
| Shadow-1 | x:0 y:1 blur:3 color:#0000001A | 카드, 입력필드 포커스 |
| Shadow-2 | x:0 y:2 blur:8 color:#00000026 | 플로팅 버튼, 드롭다운 |
| Shadow-3 | x:0 y:4 blur:16 color:#00000033 | 모달, 바텀시트 |

### 코너 라디우스

| 용도 | 값 |
|------|-----|
| 버튼 | 12px |
| 카드 | 12px |
| 입력필드 | 8px |
| 아바타 | 50% (원형) |
| 뱃지/태그 | 16px |
| 모달/바텀시트 | 16px (상단만) |
| 체크박스 | 4px |
| 토스트 메시지 | 8px |

### 컴포넌트 규격

| 컴포넌트 | 크기 | cornerRadius | 비고 |
|----------|------|-------------|------|
| 버튼 (Primary) | 360 x 52 | 12 | 배경 #2196F3, 텍스트 #FFFFFF |
| 버튼 (Secondary) | 360 x 52 | 12 | 배경 #FFFFFF, 테두리 #2196F3, 텍스트 #2196F3 |
| 버튼 (Disabled) | 360 x 52 | 12 | 배경 #E0E0E0, 텍스트 #BDBDBD |
| 입력필드 | 360 x 48 | 8 | 테두리 #E0E0E0, 포커스 시 #2196F3 |
| 입력필드 (Error) | 360 x 48 | 8 | 테두리 #F44336 |
| 카드 | 360 x 가변 | 12 | 배경 #FFFFFF, Shadow-1 |
| 리스트 아이템 | 360 x 56 | 0 | 하단 구분선 #E0E0E0 |
| 아바타 (대) | 80 x 80 | 40 | 원형 |
| 아바타 (중) | 48 x 48 | 24 | 원형 |
| 아바타 (소) | 32 x 32 | 16 | 원형 |
| 뱃지 (숫자) | 20 x 20 | 10 | 배경 #FF5722, 텍스트 #FFFFFF |
| 뱃지 (어노테이션) | 44 x 29 | 15 | 배경 #BF0F0F |
| 탭바 | 393 x 56 | 0 | 배경 #FFFFFF, 상단 구분선 |
| 토스트 메시지 | 360 x 48 | 8 | 배경 #212121 (90% 투명도), 텍스트 #FFFFFF |
| 태그/칩 | 가변 x 32 | 16 | 배경 #BBDEFB, 텍스트 #1976D2 |
| Description 프레임 | 585 x 가변 | 0 | 기존 유지 |
| 체크박스 (소) | 26 x 26 | 4 | 체크 시 배경 #2196F3 |

### 컴포넌트 상태 (States)

모든 인터랙티브 컴포넌트는 다음 상태를 Description에 명시:

| 상태 | 시각적 표현 | 설명 |
|------|------------|------|
| Default | 기본 스타일 | 초기 표시 상태 |
| Focused | 테두리 #2196F3, Shadow-1 | 입력 중 |
| Active/Selected | 배경 #BBDEFB 또는 텍스트 #2196F3 | 선택된 상태 |
| Disabled | 배경 #E0E0E0, 텍스트 #BDBDBD | 비활성 |
| Error | 테두리 #F44336, 에러 텍스트 표시 | 유효성 실패 |
| Loading | 스피너 또는 스켈레톤 UI | 데이터 로딩 중 |

## 디자인 퀄리티 원칙

### 1. 시각적 위계 (Visual Hierarchy)

화면 내 정보 우선순위를 명확히 구분:
- **1순위**: 화면 타이틀, 주요 CTA → 가장 크고 굵게
- **2순위**: 섹션 타이틀, 주요 콘텐츠 → 중간 크기
- **3순위**: 보조 정보, 메타데이터 → 작고 연한 색상
- 한 화면에 Primary 버튼은 **최대 1개**

### 2. 터치 영역 (Touch Target)

- 최소 터치 영역: **44 x 44px** (iOS HIG 기준)
- 인접 터치 요소 간 최소 간격: **8px**
- 아이콘 버튼은 시각적 크기 24px + 패딩으로 44px 확보

### 3. 정렬과 일관성

- 화면 좌우 마진: **16px** 고정
- 같은 유형의 요소는 반드시 같은 간격/크기 적용
- 텍스트 정렬: 본문은 좌측 정렬, 숫자는 우측 정렬, CTA는 중앙 정렬

### 4. 콘텐츠 밀도

- 리스트: 아이템 간 구분선 또는 12px 간격
- 카드: 16-20px 내부 패딩, 카드 간 12px 간격
- 폼: 입력필드 간 16px 간격, 라벨-필드 간 8px

### 5. 피드백과 상태 표시

모든 사용자 액션에 시각적 피드백 정의:
- 탭 → 버튼 색상 변화 (Primary Dark)
- 성공 → 토스트 메시지 (Success 색상)
- 에러 → 인라인 에러 메시지 (Error 색상)
- 로딩 → 스켈레톤 UI 또는 스피너

### 6. 빈 상태 (Empty State)

데이터 없는 화면은 반드시 빈 상태 디자인 포함:
- 일러스트 또는 아이콘 (48-64px)
- 안내 메시지 (본문 크기, 보조 텍스트 색상)
- 액션 유도 버튼 (해당 시)

## 레이아웃 패턴

### 표준 화면 구조
```
┌─────────────────────────┐
│ Status Bar (44px)       │
├─────────────────────────┤
│ Header (56px)           │
├─────────────────────────┤
│                         │
│ Content Area            │
│ (좌우 마진 16px)         │
│                         │
├─────────────────────────┤
│ Bottom CTA (선택)       │
│ (패딩 16px, Safe Area)  │
├─────────────────────────┤
│ Tab Bar (56px, 선택)    │
└─────────────────────────┘
```

### Safe Area
- 상단: Status Bar 44px
- 하단: Home Indicator 34px (CTA 버튼 아래 여백)

### 스크롤 영역
- Content Area만 스크롤, Header/TabBar 고정
- 스크롤 시 Header에 Shadow-1 추가 (Description에 명시)

## Description 컴포넌트 규칙

### 사용 방법 (CRITICAL)

화면설계 시 Description은 항상 등록된 컴포넌트를 인스턴스로 생성하여 사용한다.

```
워크플로우:
1. get_local_components()로 "Description/화면설명-v2" 컴포넌트 키 확인
2. create_component_instance(componentKey, x, y)로 인스턴스 생성
3. 인스턴스 내부 텍스트 노드를 수정 (meta 값, 섹션 타이틀/설명)
4. 필요 시 섹션 추가/삭제
```

> **절대 Description을 처음부터 만들지 마라.** 반드시 기존 컴포넌트의 인스턴스를 생성하여 사용.

### 구조 (Auto-Layout 적용)
```
Description/화면설명-v2 (COMPONENT, 585 x 가변)
├── Meta Section (VERTICAL auto-layout, itemSpacing: 5, 패딩: 0)
│   ├── Row ID (HORIZONTAL, 585x65, 패딩 15px, gap 24px)
│   │   ├── "화면 ID" (Noto Sans Bold 26px, #000000)
│   │   └── "[값]" (Noto Sans Bold 24px, #00C2FF)
│   ├── Row Path (동일 구조)
│   ├── Row Desc (동일 구조)
│   └── Row DevType (동일 구조)
├── Desc Header (HORIZONTAL, 585x59, 중앙정렬, 배경 #F2F2F2)
│   └── "Description(화면설명)" (Noto Sans Bold 26px, #000000)
└── Desc Body (VERTICAL auto-layout, itemSpacing: 20, 패딩: 상하42 좌우37, 배경 #F2F2F2)
    ├── Section 1 (VERTICAL, itemSpacing: 5)
    │   ├── Title 1 (Roboto Bold 24px, lineHeight 35px) — "1. 영역명"
    │   └── Desc 1 (Roboto Regular 24px, lineHeight 35px) — "ㆍ상세 내용"
    ├── Section 2 (동일 구조)
    └── ... (섹션 수는 화면에 따라 가변)
```

### 텍스트 작성 규칙

1. **타이틀**: Roboto Bold 24px, 번호 + 영역명 (예: `1. 헤더 영역`, `2. [BTN] 탈퇴하기`)
2. **상세 내용**: Roboto Regular 24px, 각 줄 앞에 반드시 **"ㆍ"** 불릿 추가
3. **라인높이**: 타이틀/상세 모두 35px
4. **섹션 간격**: 각 섹션(Title + Desc) 사이 20px 여백 (auto-layout itemSpacing)
5. **Bold/Regular 분리**: 한 텍스트 노드에 혼합 스타일 불가 → Title 노드(Bold) + Desc 노드(Regular) 별도 분리
6. **Auto-Layout**: 텍스트 추가/수정 시 아래 요소가 자동으로 밀려남 (겹침 없음)

## 폰트 관련 주의사항

### "Cannot unwrap symbol" 에러 대응

혼합 스타일 텍스트 노드 수정 시 발생. 해결:
1. `load_font_async`로 사용할 폰트 로드
2. `set_font_name`으로 단일 폰트 통일
3. 그 다음 `set_text_content` 실행

### 폰트 로드 필수 목록
- Roboto Bold / Regular / Medium
- Noto Sans Bold / Regular

## 클론 소스 컴포넌트 (login test 페이지 기준)

> 문서마다 ID가 다를 수 있으므로, 새 문서에서는 반드시 `get_document_info` + `get_local_components`로 재확인할 것.

| 컴포넌트 | 용도 |
|----------|------|
| iOS status bar | 상단 시스템 상태바 |
| Header group (뒤로가기 + 타이틀) | 화면 헤더 |
| Checkbox (소) | 선택 항목 |
| Checkbox (대) | 동의 체크 |
| Button (비활성) | 하단 CTA 버튼 |
| Component 25 (빨간 뱃지) | 번호 어노테이션 |
| Description/화면설명-v2 | 화면 설명서 (**항상 create_component_instance로 사용**) |

## 작업 완료 체크리스트

### 배치/구조
- [ ] 메인 화면 프레임 (0, 0) 배치 확인
- [ ] Description 컴포넌트 프레임 옆 배치 확인
- [ ] 모든 뱃지 번호 순서 확인
- [ ] 컴포넌트 에셋 등록 확인

### Description 품질
- [ ] Description 타이틀 Bold / 상세 Regular 분리 확인
- [ ] Description 상세 줄마다 "ㆍ" 불릿 확인
- [ ] 섹션 간 간격 확인
- [ ] 모든 컴포넌트 상태(Default/Focused/Disabled/Error) 명시 여부
- [ ] 빈 상태(Empty State) 정의 여부
- [ ] 에러/로딩 피드백 명시 여부

### 디자인 퀄리티
- [ ] 색상이 브랜드 컬러 시스템에 맞는지 확인
- [ ] 간격이 4px 배수 기반인지 확인
- [ ] 터치 영역 최소 44x44px 확보 확인
- [ ] 시각적 위계 — Primary 버튼 1개 이하
- [ ] 좌우 마진 16px 일관성 확인
- [ ] cornerRadius가 규격표와 일치하는지 확인
