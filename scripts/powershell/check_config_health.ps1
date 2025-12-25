# Claude Code Configuration Health Check (PowerShell)
# Run monthly to ensure optimal configuration

Write-Host "=== Claude Code Configuration Health Check ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: CLAUDE.md line count
Write-Host "1. Checking CLAUDE.md size..." -ForegroundColor Yellow
if (Test-Path "CLAUDE.md") {
    $lineCount = (Get-Content "CLAUDE.md" | Measure-Object -Line).Lines
    if ($lineCount -le 50) {
        Write-Host "   ✓ CLAUDE.md: $lineCount lines (target: <50)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ CLAUDE.md: $lineCount lines (exceeds 50 line limit)" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ CLAUDE.md not found" -ForegroundColor Red
}
Write-Host ""

# Check 2: Settings file exists
Write-Host "2. Checking .claude/settings.json..." -ForegroundColor Yellow
if (Test-Path ".claude/settings.json") {
    Write-Host "   ✓ settings.json exists" -ForegroundColor Green
    $settingsSize = (Get-Item ".claude/settings.json").Length
    if ($settingsSize -lt 3072) {
        Write-Host "   ✓ Size: $settingsSize bytes (target: <3KB)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Size: $settingsSize bytes (consider simplifying)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ settings.json not found" -ForegroundColor Red
}
Write-Host ""

# Check 3: MCP configuration
Write-Host "3. Checking .mcp.json..." -ForegroundColor Yellow
if (Test-Path ".mcp.json") {
    Write-Host "   ✓ .mcp.json exists" -ForegroundColor Green
    $mcpContent = Get-Content ".mcp.json" -Raw
    $enabledCount = ([regex]::Matches($mcpContent, '"disabled"\s*:\s*false')).Count
    Write-Host "   → Enabled MCP servers: $enabledCount"
    if ($enabledCount -gt 3) {
        Write-Host "   ⚠ Consider disabling rarely-used servers (each adds 400-800 tokens)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ .mcp.json not found (optional)" -ForegroundColor Yellow
}
Write-Host ""

# Check 4: File sizes
Write-Host "4. Configuration file sizes..." -ForegroundColor Yellow
if (Test-Path ".claude/settings.json") {
    $size = (Get-Item ".claude/settings.json").Length
    Write-Host "   settings.json: $size bytes"
}
if (Test-Path ".mcp.json") {
    $size = (Get-Item ".mcp.json").Length
    Write-Host "   .mcp.json: $size bytes"
}
Write-Host ""

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Run this check monthly to maintain optimal performance"
Write-Host "Target token usage: <25K per session"
Write-Host "Use /cost command to monitor token spending"
Write-Host ""
