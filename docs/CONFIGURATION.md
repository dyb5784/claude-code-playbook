# ⚙️ Configuration Best Practices

**Complete guide to configuring Claude Code Playbook for optimal performance and token efficiency.**

---

## 🏆 The Golden Rules

### 1. Keep CLAUDE.md under 50 lines
**Why**: More lines = more context = worse performance  
**Focus on**: commands, paths, gotchas  
**Exclude**: style guides, obvious info, lengthy docs  

✅ **Good Example** (35 lines):
```markdown
# MyProject Configuration

**Tech Stack**: Python 3.9, Django 4.0, PostgreSQL 13
**Main Commands**:
- `python manage.py runserver` - Start dev server
- `python manage.py test` - Run tests
- `python manage.py migrate` - Apply DB migrations

**Key Paths**:
- `/src/` - Main application code
- `/tests/` - Test files
- `/config/` - Configuration files

**Gotchas**:
- Always run migrations after pulling
- Use `DEBUG=True` for local development
- Database resets require superuser recreation
```

❌ **Bad Example** (80+ lines with unnecessary details):
```markdown
# MyProject Configuration

This is a Django application that I started working on in 2023...
[Lengthy project history and detailed explanations]
```

### 2. Enable only MCP servers you use >50% of sessions
**Why**: Each server adds 400-800 tokens  
**Action**: Disable unused servers immediately  
**Check**: Run `/context` to monitor token consumption  

### 3. Use allowlists, not manual permissions
**Why**: Pre-approves safe commands, reduces interruptions by 90%  
**How**: Configure `.claude/settings.json` with allowed commands  
**Pro tip**: Use `--dangerously-skip-permissions` with git safety net  

### 4. Run health checks monthly
```bash
# Monthly health check (Linux/Mac)
bash scripts/check_config_health.sh

# Monthly health check (Windows)
powershell scripts/powershell/check_config_health.ps1
```

**Benefits**:
- 🔍 Detects configuration issues before they impact productivity
- 📊 Tracks token efficiency over time
- ⚙️ Identifies unused MCP servers and commands
- 🎯 Ensures best practices compliance

### 5. Reset context every 5-7 prompts
```bash
/cost                              # Check usage
/clear                             # Reset context
claude skills refactoring catchup  # Restore context
```

**Why**: Prevents performance degradation, maintains token efficiency, preserves context quality

---

## 📊 Configuration Files Overview

| File | Purpose | Commit to Git? | Size Limit | Location |
|------|---------|----------------|------------|----------|
| CLAUDE.md | Project guidelines | ✅ Yes | <50 lines | Project root |
| .claude/settings.json | Permissions & tools | ✅ Yes | <3KB | .claude/ |
| .mcp.json | External connections | ✅ Yes | <5KB | Project root |
| CLAUDE.local.md | Personal preferences | ❌ No (gitignored) | No limit | Project root |
| REFACTOR_PROGRESS.md | Session progress | ❌ No (temporary) | No limit | Project root |

---

## 🛠️ Detailed Configuration Guide

### CLAUDE.md Template

**Location**: `templates/CLAUDE.md.template`  
**Purpose**: Main project configuration and guidelines  
**Commit**: ✅ Yes (project-specific)  

**Essential sections to customize:**
1. **Project Overview** (1-2 lines)
2. **Technology Stack** (bullet points)
3. **Key Commands** (most used commands)
4. **Important Paths** (source, tests, config)
5. **Gotchas & Warnings** (common pitfalls)
6. **Testing Instructions** (how to run tests)

### .claude/settings.json Configuration

**Location**: `templates/.claude/settings.json.template`  
**Purpose**: Claude Code permissions and tool settings  
**Commit**: ✅ Yes (project-specific)  

**Key settings to configure:**
```json
{
  "permissions": {
    "allowedCommands": [
      "git",
      "npm",
      "python",
      "pytest",
      "pip"
    ]
  },
  "contextManagement": {
    "autoClear": true,
    "maxTokens": 25000
  }
}
```

### .mcp.json Server Configuration

**Location**: `templates/.mcp.json.template`  
**Purpose**: External tool and service connections  
**Commit**: ✅ Yes (with placeholders)  

**Example configurations:**
```json
{
  "servers": {
    "github": {
      "enabled": true,
      "url": "https://api.github.com"
    },
    "database": {
      "enabled": false,
      "connection": "postgresql://localhost:5432/mydb"
    }
  }
}
```

---

## 🔧 Monthly Maintenance Checklist

Set a recurring reminder to run these checks:

```bash
# 1. Run health check (Linux/Mac)
bash scripts/check_config_health.sh

# 1. Run health check (Windows)
powershell scripts/powershell/check_config_health.ps1

# 2. Review and trim CLAUDE.md if needed
wc -l CLAUDE.md  # Target: <50 lines

# 3. Audit MCP servers
cat .mcp.json | grep "enabled.*true"

# 4. Review custom commands
ls .claude/commands/  # Remove unused commands

# 5. Update playbook (if new version available)
git pull origin main
```

**Time investment**: 10 minutes/month  
**ROI**: Prevents hours of debugging configuration issues

---

## 🚨 Common Configuration Mistakes

### 1. Overly Detailed CLAUDE.md
**Problem**: 100+ lines with project history  
**Solution**: Focus on commands, paths, gotchas - keep it under 50 lines

### 2. Too Many MCP Servers
**Problem**: Enabling all available servers  
**Solution**: Only enable servers you use >50% of the time

### 3. Manual Permission Approvals
**Problem**: Approving commands manually every session  
**Solution**: Use allowlists in `.claude/settings.json`

### 4. Never Resetting Context
**Problem**: Context grows too large, performance degrades  
**Solution**: Reset every 5-7 prompts with `/clear` + `catchup`

### 5. Ignoring Health Checks
**Problem**: Configuration drift and inefficiency  
**Solution**: Run monthly health checks

---

## 🎯 Configuration Examples by Project Type

### Python Web Application
```markdown
# MyWebApp Configuration

**Tech Stack**: Python 3.9, Django 4.0, PostgreSQL 13
**Main Commands**:
- `python manage.py runserver` - Start dev server
- `python manage.py test` - Run tests
- `python manage.py migrate` - Apply DB migrations

**Key Paths**:
- `/src/` - Main application code
- `/tests/` - Test files
- `/config/` - Configuration files

**Gotchas**:
- Always run migrations after pulling
- Use `DEBUG=True` for local development
- Database resets require superuser recreation
```

### JavaScript Frontend
```markdown
# MyFrontend Configuration

**Tech Stack**: React 18, TypeScript, Vite
**Main Commands**:
- `npm run dev` - Start development server
- `npm run test` - Run tests
- `npm run build` - Build for production

**Key Paths**:
- `/src/` - Source code
- `/tests/` - Test files
- `/public/` - Static assets

**Gotchas**:
- Node version must be 16+ for Vite
- Run `npm install` after pulling changes
- Build output goes to `/dist/`
```

---

## 📚 Related Documentation

- **[Getting Started](GETTING_STARTED.md)** - Complete setup guide
- **[Token Economics](TOKEN_ECONOMICS.md)** - Optimize token usage
- **[Shell Aliases](ALIASES.md)** - Productivity shortcuts
- **[Success Guide](SUCCESS_GUIDE.md)** - Best practices and metrics

---

## 📂 Project Structure

Understanding the playbook structure helps with configuration:

```
claude-code-playbook/
├── 📁 docs/                    # Complete documentation
│   ├── GETTING_STARTED.md     # 15-minute setup guide
│   ├── CONFIGURATION.md       # Best practices
│   ├── ALIASES.md            # Productivity shortcuts
│   ├── TOKEN_ECONOMICS.md    # Token optimization
│   ├── SUCCESS_GUIDE.md      # Success metrics & learning
│   └── windows/              # Windows-specific guides
├── 📁 scripts/               # Health check and utility scripts
│   ├── check_config_health.sh    # Linux/Mac health check
│   ├── validate_config.py        # Configuration validator
│   └── powershell/           # Windows PowerShell scripts
├── 📁 skills/                # Available skills and workflows
│   ├── python-scientific/    # Scientific computing patterns
│   └── refactoring/          # 7 refactoring workflows
├── 📁 templates/             # Ready-to-use configuration files
│   ├── CLAUDE.md.template    # Main project configuration
│   ├── .cursorrules.template # IDE integration rules
│   ├── .claude/              # Claude-specific settings
│   └── [5 more templates]    # Complete template set
└── 📄 README.md              # Main documentation entry point
```

**Templates include:** CLAUDE.md, .cursorrules, settings, MCP configs, aliases, and more.

## 🔄 Monthly Maintenance

Set a recurring reminder to:

```bash
# 1. Run health check
bash scripts/check_config_health.sh

# 2. Review and trim CLAUDE.md if needed
wc -l CLAUDE.md  # Target: <50 lines

# 3. Audit MCP servers
cat .mcp.json | grep "enabled.*true"

# 4. Review custom commands
ls .claude/commands/  # Remove unused commands

# 5. Update playbook (if new version available)
git pull origin main
```

**Next Guide**: [Token Economics](TOKEN_ECONOMICS.md) →