# Memory

## Figma Design System
- 규칙 파일: `~/.claude/rules/figma-design-system.md`
- MCP 플러그인: `~/claude-talk-to-figma-mcp` (arinspunk repo)
- 소켓 포트: 3055, 빌드: `bun run build:win`
- 컴포넌트 재사용 필수: clone_node → insert_child → move_node
- Description 컴포넌트: Bold/Regular 별도 텍스트 노드, 상세 줄마다 "ㆍ" 불릿
- 혼합 폰트 에러 대응: set_font_name으로 통일 후 set_text_content
- MCP 도구 권한: settings.json에 `mcp__ClaudeTalkToFigma__*` 허용 완료

## Figma Agents
- `fd` (sonnet): 스토리보드 설계 명세서 생성 (파일: `~/.claude/agents/fd.md`)
- `figma-designer` (sonnet): fd와 동일 (중복)
- `fb` (sonnet): batch_execute commands JSON 생성 (파일: `~/.claude/agents/fb.md`)
- `sr` (opus): CRUD 완전성 + UX 논리 검수 (파일: `~/.claude/agents/sr.md`)
- `storyboard-reviewer` (opus): sr과 동일 (중복)
- `qa-master` (opus): CRUD·상태·보안·성능 종합 QA 검증
- Figma MCP는 WebSocket 단일 채널 → 병렬 에이전트 Figma 조작 불가

### **[MANDATORY] 화면설계 요청 시 필수 에이전트 사용 규칙**
Figma MCP 서버가 구동된 상태에서 화면설계 요청이 오면, 아래 6개 에이전트를 반드시 참고하여 처리:
1. **fd** / **figma-designer** — 설계 명세서 작성
2. **fb** — Figma batch 명령 JSON 생성
3. **sr** / **storyboard-reviewer** — 설계 검수
4. **qa-master** — 종합 QA 검증

### 워크플로우 (v2 - 병렬 batch)
```
fd(설계 명세) → 사용자 승인
  → fb×N 병렬 (화면별 batch commands JSON 생성)
  → 메인 (순차 batch_execute + 텍스트 수정)
  → 검증 (export + get_node_info)
  → sr (논리 검수, 1회)
  → qa-master (종합 QA, 필요 시)
```
- 다중 화면: fb 에이전트를 화면 수만큼 병렬 실행 → 계산 시간 1/N
- 단일 화면: fb 스킵, 메인이 직접 batch 구성 (스폰 오버헤드 회피)
- fb 출력: phase1(batch commands) + phase2(텍스트 수정 지시) + phase3(Description 지시)

## User Preferences
- 언어: 한국어
- 스타일: 직접적, 간결한 답변 선호
- **출력 최소화**: 작업 중간 과정 CLI에 노출 금지. 최종 결과만 출력. 묻기 전까지 default
- **채널 ID = 화면설계 모드**: 사용자가 Figma 채널 ID를 주면 별도 지시 없어도 화면설계 작업으로 간주. 바로 연결 → 작업 대기
- **화면 = 화면 + Description 세트 (절대 규칙)**: 화면 그리기 요청 시 반드시 메인 화면 프레임 + Description 프레임을 항상 함께 생성. 어떤 세션이든 예외 없음
- Figma 작업 시 기존 양식/컴포넌트 반드시 재사용
- **sr 리뷰 1회만**: 화면설계 완료 후 sr 1회 돌리고 결과 보고. 재리뷰 반복 안 함
- 뱃지는 프레임 밖(페이지 레벨)에 배치해야 클리핑 안 됨
- **화면 제작 후 반드시 겹침 검사 실행** (execute_plugin_code로 children 순회, aBottom > bY 이면 즉시 수정)
- **Description 텍스트 수정 후 반드시 get_node_info로 실제 height 확인 → 겹침 산술 검증 → export 시각 확인** (추측 금지)
- 리뷰어에게 좌표 데이터 넘길 때 반드시 실제 height 포함. height 없는 데이터로 리뷰 돌리지 말 것
- **Description 내용은 기능 위주만 작성** — 색상 정보, 글씨 두께 등 시각적 스타일 정보 넣지 않음
- 텍스트 정렬 오차 2px 이내 준수
- 빨간 뱃지는 객체 왼쪽 1/3 겹침 배치: `badge.x = element.x - Math.round(44 * 2/3)` = element.x - 29
- 텍스트/이모지 아이콘 사용 금지
- **화면 제작 시 행간·객체 간격 반드시 확인**: 본문 lineHeight 최소 1.4x (13px→18-19px, 14px→20-21px, 15px→22px), 객체 간 최소 8-10px 간격 유지, 겹침 절대 금지

## Screen Index 관리
- 화면 생성 후 해당 페이지의 `Common/Screen Index` 컴포넌트에 행 추가 필수
- Screen Index 없으면 새로 생성 (750px 폭, Title Row + Header Row + Data Rows)
- 행 구조: ScreenID | 페이지명 | 페이지 설명 (Inter 14px, 행높이 44px)
- 짝수 행 배경 #fafafa, 홀수 행 #ffffff
- Description 메타 값(화면 ID, 화면설명)에서 데이터 추출

## Figma 제작 최적화 (Blueprint-First + Batch + execute_plugin_code)

### 속도 우선순위
1. **execute_plugin_code** — 반복/루프 요소 최적 (폰트 캐시 내장, JS 루프 = RTT 1회)
2. **batch_execute** — 고정된 N개 명령 (RTT 1회, $N 참조 파이프라인)
3. 개별 MCP 호출 — 사용 금지 (각 명령마다 RTT 누적)

### 선택 기준
| 상황 | 도구 |
|------|------|
| 리스트/그리드 반복 생성 | `execute_plugin_code` (JS for 루프) |
| 동적 개수, 조건 분기 | `execute_plugin_code` |
| 고정된 N개 요소 (의존성 있음) | `batch_execute` ($N 참조) |
| 노드 ID 캐싱 (세션 간) | `execute_plugin_code` + `storage` |

### execute_plugin_code 패턴
```js
// 폰트 1회 로드 → 이후 캐시 히트 (F.loadFont)
await F.loadFont('Roboto', 'Regular');
// JS 루프로 반복 요소 생성
for (let i = 0; i < items.length; i++) {
  await F.listItem(items[i], frameId, { y: i * 56 });
}
storage.frameId = frame.id; // ID 캐시
```
- timeout: **120초** (수정됨, 기존 30초)
- 결과는 plain object만 반환 (Figma 노드 직접 반환 불가)

### F 내장 UI 컴포넌트 헬퍼 (code.js 추가됨)
| 함수 | 용도 | 주요 옵션 |
|------|------|----------|
| `F.statusBar(parentId, opts)` | Status Bar (393×44) | opts.time |
| `F.inputField(label, placeholder, parentId, opts)` | 입력 필드 (361×56) | opts.x, opts.y, opts.error |
| `F.primaryButton(label, parentId, opts)` | Primary 버튼 (361×52) | opts.x, opts.y, opts.disabled |
| `F.outlineButton(label, parentId, opts)` | Outline 버튼 (361×52) | opts.bgColor, opts.textColor |
| `F.listItem(text, parentId, opts)` | 리스트 아이템 (393×56) | opts.bgColor |
| `F.sectionHeader(text, parentId, opts)` | 섹션 헤더 (393×32) | - |
| `F.tabBar(tabs, parentId, opts)` | 탭바 (393×56) | opts.y, opts.activeIndex |
| `F.badge(number, parentId, opts)` | 뱃지 (44×29, #BF0F0F) | opts.x, opts.y |

**badge 컴포넌트 key**: `d178a2485ff4307b1116ebee11695d75c0d3ccef`
- 플러그인 재시작 필요 (code.js 변경 시)

### batch_execute 최적화 (수정됨)
- `create_text` 명령의 fontFamily를 **Promise.all로 사전 병렬 로드** (동일 폰트 반복 loadFontAsync 제거)
- 빌드: `bun run build:win` 완료

### 공통 규칙
- **사전 계산 → 1회 전송 → 최종 검증** 패턴 필수
- export + 검증은 마지막 1회만
- 플러그인 코드(code.js) 수정 후 Figma에서 플러그인 재시작 필요

## Figma Components
- **M3 컴포넌트 우선 사용** (fd.md의 Default_Components 30개)
- 커스텀 컴포넌트는 M3에 없는 경우만 사용
- 화면 제작 전 반드시 fd.md 컴포넌트 레지스트리 참조
- M3 컴포넌트 key 참조: `~/.claude/agents/fd.md` Default_Components 섹션

### 재사용 컴포넌트 (커스텀)
| 컴포넌트 | Key | 용도 |
|----------|-----|------|
| UI/List Item | be22cc80197f7b1584213c1b8f70e88ee78d565e | 리스트 항목 (393x56, 텍스트+chevron+divider) |
| UI/Section Header | af8b746896b5c89f6566ddb593963efe8c97c314 | 섹션 헤더 (393x32, #F5F5F5 배경) |
| Template/Screen Base | a7fc300d794c22c6b6a6574d577f27c88ec7537a | 화면 골격 (Status Bar+Header+Tab Bar 포함) |
