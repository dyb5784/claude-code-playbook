#!/bin/bash

# Claude Code Configuration Health Check
# Run monthly to maintain optimal configuration

set -e

echo "╔══════════════════════════════════════════════════════╗"
echo "║   Claude Code Configuration Health Check            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

ISSUES_FOUND=0
WARNINGS_FOUND=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
error() {
    echo -e "${RED}❌ $1${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

section() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════════════════"
}

# Check 1: CLAUDE.md Size and Content
section "1. CLAUDE.md Validation"

if [ ! -f "CLAUDE.md" ]; then
    error "CLAUDE.md not found in current directory"
else
    lines=$(wc -l < CLAUDE.md)
    echo "   Lines: $lines"
    
    if [ "$lines" -lt 30 ]; then
        warning "CLAUDE.md seems too small ($lines lines). Consider adding more context."
    elif [ "$lines" -lt 50 ]; then
        success "CLAUDE.md size optimal ($lines lines)"
    elif [ "$lines" -lt 100 ]; then
        warning "CLAUDE.md is large ($lines lines). Consider trimming to <50."
    else
        error "CLAUDE.md too large ($lines lines). Trim to <50 for optimal performance."
    fi
    
    # Check for anti-patterns
    if grep -qi "indentation\|spaces\|tabs" CLAUDE.md; then
        warning "CLAUDE.md contains style guide content (use linters instead)"
    fi
    
    if grep -qi "write clean code\|follow best practices" CLAUDE.md; then
        warning "CLAUDE.md contains generic advice (remove for clarity)"
    fi
    
    # Check for essential sections
    if ! grep -qi "budget\|token" CLAUDE.md; then
        warning "CLAUDE.md missing budget/token constraints section"
    fi
    
    if ! grep -qi "validation\|test" CLAUDE.md; then
        warning "CLAUDE.md missing validation requirements"
    fi
fi

# Check 2: MCP Server Configuration
section "2. MCP Server Audit"

if [ -f ".mcp.json" ]; then
    if command -v jq &> /dev/null; then
        servers=$(jq '.mcpServers | length' .mcp.json 2>/dev/null || echo "0")
        enabled=$(jq '[.mcpServers[] | select(.enabled == true)] | length' .mcp.json 2>/dev/null || echo "0")
        
        echo "   Total MCP servers configured: $servers"
        echo "   Enabled: $enabled"
        
        if [ "$enabled" -eq 0 ]; then
            info "No MCP servers enabled (this is fine if not needed)"
        elif [ "$enabled" -gt 4 ]; then
            warning "Many MCP servers enabled ($enabled). Each adds 400-800 tokens."
            echo "      Consider disabling unused servers."
        else
            success "MCP server count optimal ($enabled enabled)"
        fi
        
        # List enabled servers
        if [ "$enabled" -gt 0 ]; then
            echo ""
            echo "   Enabled servers:"
            jq -r '.mcpServers | to_entries[] | select(.value.enabled == true) | "      - \(.key)"' .mcp.json 2>/dev/null || true
        fi
    else
        info ".mcp.json exists but jq not installed (install jq for detailed analysis)"
    fi
else
    info "No .mcp.json found (MCP servers not configured)"
fi

# Check 3: Slash Commands
section "3. Custom Slash Commands"

if [ -d ".claude/commands" ]; then
    cmd_count=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l)
    echo "   Custom commands found: $cmd_count"
    
    if [ "$cmd_count" -eq 0 ]; then
        info "No custom commands (consider adding workflow shortcuts)"
    else
        success "Custom commands configured"
        
        # Check for stale commands (not modified in 90 days)
        old_commands=$(find .claude/commands -name "*.md" -mtime +90 2>/dev/null)
        if [ -n "$old_commands" ]; then
            warning "Commands not modified in 90+ days:"
            echo "$old_commands" | while read -r cmd; do
                echo "      - $(basename "$cmd")"
            done
            echo "      Consider removing if unused."
        fi
    fi
else
    info "No .claude/commands directory (custom commands not set up)"
fi

# Check 4: Permission Allowlist
section "4. Permission Configuration"

if [ -f ".claude/settings.json" ]; then
    if command -v jq &> /dev/null; then
        allowed_count=$(jq '.allowedCommands | length' .claude/settings.json 2>/dev/null || echo "0")
        allowed_tools=$(jq '.allowedTools | length' .claude/settings.json 2>/dev/null || echo "0")
        
        echo "   Allowed commands: $allowed_count"
        echo "   Allowed tools: $allowed_tools"
        
        if [ "$allowed_count" -eq 0 ]; then
            warning "No commands in allowlist (consider adding safe commands)"
        elif [ "$allowed_count" -lt 10 ]; then
            warning "Small allowlist ($allowed_count commands). May cause permission prompts."
        elif [ "$allowed_count" -lt 25 ]; then
            success "Allowlist size optimal ($allowed_count commands)"
        else
            warning "Large allowlist ($allowed_count commands). Review for unused entries."
        fi
    else
        info ".claude/settings.json exists but jq not installed"
    fi
else
    warning ".claude/settings.json not found. Using default permissions."
    echo "      Consider creating from template."
fi

# Check 5: .gitignore Coverage
section "5. Git Ignore Configuration"

if [ -f ".gitignore" ]; then
    if grep -q ".claude/CLAUDE.local.md" .gitignore; then
        success "Personal Claude configs properly ignored"
    else
        warning ".gitignore missing .claude/CLAUDE.local.md"
        echo "      Add: .claude/CLAUDE.local.md"
    fi
    
    if grep -q "REFACTOR_PROGRESS.md" .gitignore; then
        success "Temporary progress files ignored"
    else
        info "Consider adding REFACTOR_PROGRESS.md to .gitignore"
    fi
else
    error ".gitignore not found in project"
fi

# Check 6: Skills Directory
section "6. Skills System"

if [ -d ".claude/skills" ]; then
    skill_count=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    echo "   Skills installed: $skill_count"
    
    if [ "$skill_count" -eq 0 ]; then
        error "Skills directory exists but no skills found"
    else
        success "Skills system configured"
        find .claude/skills -mindepth 1 -maxdepth 1 -type d | while read -r skill; do
            echo "      - $(basename "$skill")"
        done
    fi
else
    error ".claude/skills directory not found"
    echo "      Skills are required for workflows to function."
fi

# Check 7: Git Repository Status
section "7. Git Repository Health"

if git rev-parse --git-dir > /dev/null 2>&1; then
    success "Git repository initialized"
    
    # Check for uncommitted Claude files
    if git status --porcelain | grep -q "CLAUDE.md\|.claude/"; then
        warning "Uncommitted Claude configuration changes"
        echo "      Consider committing to share with team."
    fi
    
    # Check if .claude is tracked
    if git ls-files --error-unmatch .claude/settings.json > /dev/null 2>&1; then
        success "Claude configuration tracked in git"
    else
        warning ".claude/settings.json not tracked in git"
        echo "      Consider committing to share team settings."
    fi
else
    error "Not a git repository"
    echo "      Claude Code works best with version control."
fi

# Check 8: File Sizes
section "8. Configuration File Sizes"

check_file_size() {
    file=$1
    warn_size=$2
    error_size=$3
    
    if [ -f "$file" ]; then
        size=$(wc -c < "$file")
        kb=$((size / 1024))
        
        echo "   $file: ${kb}KB"
        
        if [ "$size" -gt "$error_size" ]; then
            error "File too large (${kb}KB). May slow down context loading."
        elif [ "$size" -gt "$warn_size" ]; then
            warning "File large (${kb}KB). Consider trimming."
        else
            success "File size optimal (${kb}KB)"
        fi
    fi
}

check_file_size "CLAUDE.md" 5120 10240  # Warn at 5KB, error at 10KB
check_file_size ".claude/settings.json" 2048 5120  # Warn at 2KB, error at 5KB

# Check 9: Validation Commands
section "9. Validation Commands"

if [ -f "CLAUDE.md" ]; then
    echo "   Checking for validation commands in CLAUDE.md..."
    
    has_test=false
    has_lint=false
    has_type=false
    
    if grep -qi "test\|pytest\|jest" CLAUDE.md; then
        has_test=true
        success "Test command documented"
    fi
    
    if grep -qi "lint\|flake8\|eslint" CLAUDE.md; then
        has_lint=true
        success "Lint command documented"
    fi
    
    if grep -qi "type-check\|mypy\|tsc" CLAUDE.md; then
        has_type=true
        success "Type check command documented"
    fi
    
    if ! $has_test; then
        warning "No test command found in CLAUDE.md"
    fi
    
    if ! $has_lint; then
        warning "No lint command found in CLAUDE.md"
    fi
    
    if ! $has_type; then
        info "No type check command found (may not be applicable)"
    fi
fi

# Summary
section "Health Check Summary"

echo ""
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  🎉 EXCELLENT! Configuration is healthy             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠️  GOOD - Minor improvements recommended           ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Warnings: $WARNINGS_FOUND"
    echo ""
    echo "Your configuration works but could be optimized."
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ ISSUES FOUND - Action required                   ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Critical issues: $ISSUES_FOUND"
    echo "Warnings: $WARNINGS_FOUND"
    echo ""
    echo "Please address critical issues before continuing."
    exit 1
fi
