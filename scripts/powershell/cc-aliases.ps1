# Claude Code Productivity Aliases for PowerShell
# Auto-loaded from PowerShell profile

# Basic Claude Code shortcuts
function cc { claude }
function cchelp { claude /help }
function cccost { claude /cost }
function ccclear { claude /clear }

# Workflow shortcuts
function cctriage { claude "Run triage workflow" }
function ccnew { claude "Start new feature workflow" }
function ccextract { claude "Extract code to separate module" }
function ccplan { claude "Create implementation plan" }
function cccode { claude "Implement planned changes" }
function ccreview { claude "Review recent code changes" }
function ccfix { claude "Fix identified issue" }
function ccmodernize { claude "Modernize code patterns" }
function cccatchup { claude "Catch up on recent changes" }

# Git + Claude workflows
function cccommit {
    git status
    git diff
    claude "Create appropriate commit"
}
function ccpr { claude "Create pull request for current changes" }

# Health checks
function cchealth { bash "$HOME/.local/bin/scripts/check_config_health.sh" }
function cchealthps { pwsh -NoProfile -Command "& '$HOME/.local/bin/scripts/check_config_health.ps1'" }

# Configuration viewers
function ccconfig { Get-Content "$HOME/.local/bin/CLAUDE.md" }
function ccsettings { Get-Content "$HOME/.local/bin/.claude/settings.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10 }
function ccmcp { Get-Content "$HOME/.local/bin/.mcp.json" | ConvertFrom-Json | ConvertTo-Json -Depth 10 }

# Quick navigation
function cdclaude { Set-Location "$HOME/.local/bin" }
function cdbsi { Set-Location "G:\bsi-vortrag" }

# Testing shortcuts (for Python projects)
function cctest { python -m pytest tests/ -xvs }
function cctype { python -m mypy src/ }
function cclint { flake8 src/ }
function cccheck {
    Write-Host "Running type check..." -ForegroundColor Cyan
    python -m mypy src/
    if ($LASTEXITCODE -ne 0) { return }

    Write-Host "`nRunning linter..." -ForegroundColor Cyan
    flake8 src/
    if ($LASTEXITCODE -ne 0) { return }

    Write-Host "`nRunning tests..." -ForegroundColor Cyan
    python -m pytest tests/ -xvs
}

# List all cc* aliases
function cclist {
    Write-Host "`nClaude Code Aliases:" -ForegroundColor Cyan
    Get-Command -Name cc* | Where-Object { $_.CommandType -eq 'Function' } |
        Sort-Object Name |
        Format-Table Name, @{Label="Type";Expression={"Function"}} -AutoSize
}

Write-Host "Claude Code aliases loaded! Type 'cclist' to see all shortcuts" -ForegroundColor Green
