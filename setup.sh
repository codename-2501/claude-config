#!/usr/bin/env bash
# Claude Code + Figma MCP Setup Script (macOS / Linux)
# Usage: bash setup.sh
# Usage with custom path: FIGMA_MCP_DIR=~/my-tools/figma-mcp bash setup.sh

set -e

FIGMA_MCP_DIR="${FIGMA_MCP_DIR:-$HOME/figma-mcp}"
FIGMA_MCP_REPO="https://github.com/codename-2501/figma-mcp.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DEST="$HOME/.claude"

echo ""
echo "=== Claude Code + Figma MCP Setup ==="
echo "figma-mcp install path: $FIGMA_MCP_DIR"
echo ""

# 1. Prerequisites
for cmd in git bun; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[ERROR] '$cmd' not found."
        [ "$cmd" = "bun" ] && echo "  → curl -fsSL https://bun.sh/install | bash"
        exit 1
    fi
done
echo "[OK] Prerequisites: git, bun"

# 2. Clone & build figma-mcp
if [ -d "$FIGMA_MCP_DIR" ]; then
    echo "[INFO] figma-mcp already exists, pulling latest..."
    git -C "$FIGMA_MCP_DIR" pull origin main
else
    echo "[INFO] Cloning figma-mcp..."
    git clone "$FIGMA_MCP_REPO" "$FIGMA_MCP_DIR"
fi

echo "[INFO] Installing dependencies..."
bun install --cwd "$FIGMA_MCP_DIR"

echo "[INFO] Building..."
bun run --cwd "$FIGMA_MCP_DIR" build
echo "[OK] figma-mcp built"

# 3. Copy claude-config to ~/.claude
echo "[INFO] Copying config to $CLAUDE_DEST ..."
mkdir -p "$CLAUDE_DEST"
for folder in agents rules commands skills hooks; do
    if [ -d "$SCRIPT_DIR/$folder" ]; then
        cp -r "$SCRIPT_DIR/$folder" "$CLAUDE_DEST/"
        echo "  → $folder"
    fi
done

# settings.json: only if not exists
if [ ! -f "$CLAUDE_DEST/settings.json" ]; then
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DEST/settings.json"
    echo "  → settings.json (new)"
else
    echo "  → settings.json (skipped, already exists)"
fi
echo "[OK] Config files copied"

# 3-1. MEMORY.md → 머신별 올바른 경로에 배치
# 경로 인코딩: /Users/john → -Users-john (슬래시→대시)
HOME_ENCODED="${HOME//\//-}"
MEMORY_DIR="$HOME/.claude/projects/$HOME_ENCODED/memory"
mkdir -p "$MEMORY_DIR"
if [ -f "$SCRIPT_DIR/memory/MEMORY.md" ]; then
    cp "$SCRIPT_DIR/memory/MEMORY.md" "$MEMORY_DIR/MEMORY.md"
    echo "  → memory/MEMORY.md → $MEMORY_DIR"
fi
echo "[OK] MEMORY.md 배치 완료"

# 4. Generate ~/.mcp.json
MCP_TEMPLATE="$SCRIPT_DIR/.mcp.json.template"
MCP_DEST="$HOME/.mcp.json"
MCP_CONTENT=$(sed "s|{{FIGMA_MCP_DIR}}|$FIGMA_MCP_DIR|g" "$MCP_TEMPLATE")

if [ -f "$MCP_DEST" ]; then
    echo "[INFO] ~/.mcp.json already exists. Please manually add ClaudeTalkToFigma entry:"
    echo "$MCP_CONTENT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['mcpServers']['ClaudeTalkToFigma'], indent=2))"
else
    echo "$MCP_CONTENT" > "$MCP_DEST"
    echo "[OK] ~/.mcp.json created"
fi

# 5. Done
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "  1. Install Figma plugin (dev mode):"
echo "     Figma → Resources → Development → Import from manifest"
echo "     → $FIGMA_MCP_DIR/src/claude_mcp_plugin/manifest.json"
echo ""
echo "  2. Start socket server (separate terminal):"
echo "     cd $FIGMA_MCP_DIR && bun run socket"
echo ""
echo "  3. Open Claude Code CLI:"
echo "     claude"
echo ""
echo "  4. Connect Figma plugin, then tell Claude:"
echo "     'Connect to Figma, channel <your-channel-id>'"
echo ""
