# Claude Code + Figma MCP Setup Script (Windows PowerShell)
# Usage: .\setup.ps1
# Usage with custom path: .\setup.ps1 -FigmaMcpDir "D:\my-tools\figma-mcp"

param(
    [string]$FigmaMcpDir = "$env:USERPROFILE\figma-mcp"
)

$ErrorActionPreference = "Stop"
$ClaudeConfigRepo = "https://github.com/codename-2501/claude-config.git"
$FigmaMcpRepo     = "https://github.com/codename-2501/figma-mcp.git"

Write-Host "`n=== Claude Code + Figma MCP Setup ===" -ForegroundColor Cyan
Write-Host "figma-mcp install path: $FigmaMcpDir`n"

# 1. Prerequisites check
foreach ($cmd in @("git", "bun")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] '$cmd' not found. Please install it first." -ForegroundColor Red
        if ($cmd -eq "bun") { Write-Host "  → https://bun.sh" }
        exit 1
    }
}
Write-Host "[OK] Prerequisites: git, bun" -ForegroundColor Green

# 2. Clone & build figma-mcp
if (Test-Path $FigmaMcpDir) {
    Write-Host "[INFO] figma-mcp already exists at $FigmaMcpDir, pulling latest..." -ForegroundColor Yellow
    git -C $FigmaMcpDir pull origin main
} else {
    Write-Host "[INFO] Cloning figma-mcp..." -ForegroundColor Yellow
    git clone $FigmaMcpRepo $FigmaMcpDir
}

Write-Host "[INFO] Installing dependencies..." -ForegroundColor Yellow
bun install --cwd $FigmaMcpDir

Write-Host "[INFO] Building (Windows)..." -ForegroundColor Yellow
$env:PATH = "$FigmaMcpDir\node_modules\.bin;" + $env:PATH
bun run --cwd $FigmaMcpDir build:win
Write-Host "[OK] figma-mcp built" -ForegroundColor Green

# 3. Copy claude-config to ~/.claude
$ClaudeDest = "$env:USERPROFILE\.claude"
$ScriptDir  = $PSScriptRoot

Write-Host "[INFO] Copying config to $ClaudeDest ..." -ForegroundColor Yellow
$foldersToSync = @("agents", "rules", "commands", "skills", "hooks")
foreach ($folder in $foldersToSync) {
    $src = Join-Path $ScriptDir $folder
    $dst = Join-Path $ClaudeDest $folder
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "  → $folder" -ForegroundColor Gray
    }
}

# settings.json: merge (only if not exists, don't overwrite user's)
$settingsDst = Join-Path $ClaudeDest "settings.json"
if (-not (Test-Path $settingsDst)) {
    Copy-Item (Join-Path $ScriptDir "settings.json") $settingsDst
    Write-Host "  → settings.json (new)" -ForegroundColor Gray
} else {
    Write-Host "  → settings.json (skipped, already exists)" -ForegroundColor Yellow
}
Write-Host "[OK] Config files copied" -ForegroundColor Green

# 3-1. MEMORY.md → 머신별 올바른 경로에 배치
# 경로 인코딩: C:\Users\john → C--Users-john (콜론→대시, 백슬래시→대시)
$homeEncoded = $env:USERPROFILE.Replace(":", "-").Replace("\", "-")
$memoryDir = Join-Path $ClaudeDest "projects\$homeEncoded\memory"
New-Item -ItemType Directory -Force -Path $memoryDir | Out-Null
$memorySrc = Join-Path $ScriptDir "memory\MEMORY.md"
$memoryDst = Join-Path $memoryDir "MEMORY.md"
if (Test-Path $memorySrc) {
    Copy-Item $memorySrc $memoryDst -Force
    Write-Host "  → memory/MEMORY.md → $memoryDir" -ForegroundColor Gray
}
Write-Host "[OK] MEMORY.md 배치 완료" -ForegroundColor Green

# 4. Generate ~/.mcp.json
$mcpTemplate = Get-Content (Join-Path $ScriptDir ".mcp.json.template") -Raw
# Convert Windows backslashes to forward slashes for JSON safety
$mcpPath = $FigmaMcpDir.Replace("\", "/")
$mcpContent = $mcpTemplate.Replace("{{FIGMA_MCP_DIR}}", $mcpPath)

$mcpDest = "$env:USERPROFILE\.mcp.json"
if (Test-Path $mcpDest) {
    Write-Host "[INFO] ~/.mcp.json already exists. Merging ClaudeTalkToFigma entry..." -ForegroundColor Yellow
    $existing = Get-Content $mcpDest -Raw | ConvertFrom-Json
    $new = $mcpContent | ConvertFrom-Json
    # Add ClaudeTalkToFigma server
    $existing.mcpServers | Add-Member -NotePropertyName "ClaudeTalkToFigma" `
        -NotePropertyValue $new.mcpServers.ClaudeTalkToFigma -Force
    $existing | ConvertTo-Json -Depth 10 | Set-Content $mcpDest
} else {
    Set-Content $mcpDest $mcpContent
}
Write-Host "[OK] ~/.mcp.json configured" -ForegroundColor Green

# 5. Done — print next steps
Write-Host "`n=== Setup Complete! ===" -ForegroundColor Cyan
Write-Host @"

Next steps:
  1. Install Figma plugin (dev mode):
     Figma → Resources → Development → Import from manifest
     → $FigmaMcpDir\src\claude_mcp_plugin\manifest.json

  2. Start socket server (run this in a separate terminal):
     cd $FigmaMcpDir && bun run socket

  3. Open Claude Code CLI in any project directory:
     claude

  4. Connect Figma plugin to a channel, then tell Claude:
     "Connect to Figma, channel <your-channel-id>"

"@ -ForegroundColor White
