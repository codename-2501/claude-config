# claude-config

Claude Code 설정 + Figma MCP 헬퍼 — 어느 머신에서든 동일한 환경 구성.

## 포함 내용

| 경로 | 설명 |
|------|------|
| `agents/` | fd, fb, sr, qa-master 등 Figma 설계 에이전트 |
| `rules/` | 코딩 스타일, 보안, Figma 디자인 시스템 규칙 |
| `commands/` | /commit, /plan, /code-review 등 슬래시 커맨드 |
| `skills/` | 추가 스킬 패키지 |
| `hooks/` | 자동화 훅 |
| `settings.json` | 권한, 환경변수 설정 |
| `.mcp.json.template` | MCP 서버 설정 템플릿 |

## 빠른 설치

### Windows (PowerShell)
```powershell
git clone https://github.com/codename-2501/claude-config.git
cd claude-config
.\setup.ps1
```

### macOS / Linux
```bash
git clone https://github.com/codename-2501/claude-config.git
cd claude-config
bash setup.sh
```

### 커스텀 경로
```powershell
# Windows — figma-mcp를 다른 드라이브에 설치
.\setup.ps1 -FigmaMcpDir "D:\tools\figma-mcp"
```
```bash
# macOS/Linux
FIGMA_MCP_DIR=~/tools/figma-mcp bash setup.sh
```

## 설치 후 사용법

1. **소켓 서버 실행** (별도 터미널):
   ```
   cd ~/figma-mcp && bun run socket
   ```

2. **Figma 플러그인 설치** (최초 1회):
   - Figma → Resources → Development → Import from manifest
   - `~/figma-mcp/src/claude_mcp_plugin/manifest.json` 선택

3. **Claude Code 실행**:
   ```
   claude
   ```

4. **Figma 채널 연결**:
   - Figma 플러그인에서 채널 ID 확인
   - Claude에게: `Connect to Figma, channel <채널ID>`

## 업데이트

설정 변경 후:
```bash
cd claude-config
git add . && git commit -m "update: ..." && git push
```

다른 머신에서 동기화:
```bash
cd claude-config && git pull
bash setup.sh  # 덮어쓰기 안전 (settings.json은 이미 있으면 스킵)
```
