#!/usr/bin/env python3
"""
Claude Code Configuration Validator

Validates configuration files for common issues and provides actionable feedback.
Run before committing Claude Code configuration changes.
"""

import json
import sys
from pathlib import Path
from typing import List, Tuple

# ANSI color codes
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
GREEN = '\033[0;32m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color


class ConfigValidator:
    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.info: List[str] = []
    
    def error(self, message: str) -> None:
        """Add critical error."""
        self.errors.append(f"{RED}❌ {message}{NC}")
    
    def warning(self, message: str) -> None:
        """Add warning."""
        self.warnings.append(f"{YELLOW}⚠️  {message}{NC}")
    
    def info_msg(self, message: str) -> None:
        """Add informational message."""
        self.info.append(f"{BLUE}ℹ️  {message}{NC}")
    
    def success(self, message: str) -> None:
        """Add success message."""
        print(f"{GREEN}✅ {message}{NC}")
    
    def validate_claude_md(self) -> None:
        """Validate CLAUDE.md file."""
        print("\n" + "=" * 60)
        print("  Validating CLAUDE.md")
        print("=" * 60)
        
        path = Path("CLAUDE.md")
        
        if not path.exists():
            self.error("CLAUDE.md not found in current directory")
            return
        
        try:
            # FIX: Explicitly use UTF-8 encoding
            content = path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            # Fallback to latin-1 if UTF-8 fails
            try:
                content = path.read_text(encoding='latin-1')
                self.warning("CLAUDE.md has encoding issues. Consider converting to UTF-8.")
            except Exception as e:
                self.error(f"Cannot read CLAUDE.md: {e}")
                return
        
        lines = content.split('\n')
        line_count = len(lines)
        
        # Check size
        print(f"   Lines: {line_count}")
        
        if line_count < 30:
            self.warning(f"CLAUDE.md seems small ({line_count} lines). "
                        "Consider adding more context.")
        elif line_count <= 50:
            self.success(f"CLAUDE.md size optimal ({line_count} lines)")
        elif line_count <= 100:
            self.warning(f"CLAUDE.md is large ({line_count} lines). "
                        "Consider trimming to <50.")
        else:
            self.error(f"CLAUDE.md too large ({line_count} lines). "
                      "Trim to <50 for optimal token efficiency.")
        
        # Check for anti-patterns
        anti_patterns = {
            'style_guide': ['indentation', 'spaces', 'tabs', 'semicolon'],
            'generic_advice': ['write clean code', 'follow best practices', 
                             'use meaningful names'],
            'obvious_descriptions': ['contains', 'this folder has', 'includes']
        }
        
        for pattern_type, keywords in anti_patterns.items():
            for keyword in keywords:
                if keyword.lower() in content.lower():
                    if pattern_type == 'style_guide':
                        self.warning(f"Contains style guide content: '{keyword}' "
                                   "(use linters instead)")
                        break
                    elif pattern_type == 'generic_advice':
                        self.warning(f"Contains generic advice: '{keyword}' "
                                   "(remove for clarity)")
                        break
        
        # Check for essential sections
        essential_keywords = {
            'budget': ['budget', 'token', 'prompt', 'cost'],
            'validation': ['test', 'lint', 'validation', 'check'],
            'commands': ['command', 'run', 'execute']
        }
        
        for section, keywords in essential_keywords.items():
            if not any(kw in content.lower() for kw in keywords):
                self.warning(f"Missing {section} section/keywords")
        
        # Check character count (affects token usage)
        char_count = len(content)
        kb_size = char_count / 1024
        
        if kb_size > 10:
            self.error(f"File too large ({kb_size:.1f}KB). "
                      "Will significantly impact token budget.")
        elif kb_size > 5:
            self.warning(f"File large ({kb_size:.1f}KB). "
                        "Consider trimming.")
    
    def validate_settings_json(self) -> None:
        """Validate .claude/settings.json file."""
        print("\n" + "=" * 60)
        print("  Validating .claude/settings.json")
        print("=" * 60)
        
        path = Path(".claude/settings.json")
        
        if not path.exists():
            self.info_msg(".claude/settings.json not found (using defaults)")
            return
        
        try:
            # FIX: Explicitly use UTF-8 encoding
            with open(path, encoding='utf-8') as f:
                config = json.load(f)
        except json.JSONDecodeError as e:
            self.error(f"Invalid JSON in settings.json: {e}")
            return
        except UnicodeDecodeError:
            self.warning("settings.json has encoding issues. Should be UTF-8.")
            return
        except Exception as e:
            self.error(f"Error reading settings.json: {e}")
            return
        
        # Check structure
        if 'allowedTools' not in config:
            self.warning("No 'allowedTools' defined")
        else:
            tools = config['allowedTools']
            print(f"   Allowed tools: {len(tools)}")
            if len(tools) == 0:
                self.warning("No tools in allowlist (may cause permission prompts)")
        
        if 'allowedCommands' not in config:
            self.warning("No 'allowedCommands' defined")
        else:
            commands = config['allowedCommands']
            cmd_count = len(commands)
            print(f"   Allowed commands: {cmd_count}")
            
            if cmd_count == 0:
                self.warning("Empty allowlist (will prompt for all commands)")
            elif cmd_count < 10:
                self.info_msg(f"Small allowlist ({cmd_count}). "
                             "Consider adding common safe commands.")
            elif cmd_count <= 25:
                self.success(f"Allowlist size optimal ({cmd_count} commands)")
            else:
                self.warning(f"Large allowlist ({cmd_count} commands). "
                           "Review for unused entries.")
            
            # Check for dangerous commands
            dangerous = ['rm -rf', 'sudo', 'chmod 777', 'drop database']
            for cmd in commands:
                for danger in dangerous:
                    if danger in cmd.lower():
                        self.error(f"Dangerous command in allowlist: '{cmd}'")
        
        # Check MCP servers in settings
        if 'mcpServers' in config:
            servers = config['mcpServers']
            if len(servers) > 0:
                self.info_msg(f"MCP servers in settings.json: {len(servers)} "
                            "(consider moving to .mcp.json)")
        
        self.success("settings.json structure valid")
    
    def validate_mcp_json(self) -> None:
        """Validate .mcp.json file."""
        print("\n" + "=" * 60)
        print("  Validating .mcp.json")
        print("=" * 60)
        
        path = Path(".mcp.json")
        
        if not path.exists():
            self.info_msg(".mcp.json not found (MCP servers not configured)")
            return
        
        try:
            # FIX: Explicitly use UTF-8 encoding
            with open(path, encoding='utf-8') as f:
                config = json.load(f)
        except json.JSONDecodeError as e:
            self.error(f"Invalid JSON in .mcp.json: {e}")
            return
        except UnicodeDecodeError:
            self.warning(".mcp.json has encoding issues. Should be UTF-8.")
            return
        
        if 'mcpServers' not in config:
            self.warning(".mcp.json missing 'mcpServers' key")
            return
        
        servers = config['mcpServers']
        total = len(servers)
        enabled = sum(1 for s in servers.values() 
                     if isinstance(s, dict) and s.get('enabled', False))
        
        print(f"   Total servers: {total}")
        print(f"   Enabled: {enabled}")
        
        if enabled == 0:
            self.info_msg("No MCP servers enabled (fine if not needed)")
        elif enabled <= 3:
            self.success(f"MCP server count optimal ({enabled} enabled)")
        elif enabled <= 5:
            self.warning(f"Several MCP servers enabled ({enabled}). "
                        "Each adds 400-800 tokens.")
        else:
            self.error(f"Too many MCP servers enabled ({enabled}). "
                      "Disable unused servers to save tokens.")
        
        # Check server configurations
        for name, server_config in servers.items():
            if not isinstance(server_config, dict):
                continue
            
            if 'command' not in server_config:
                self.warning(f"Server '{name}' missing 'command' field")
            
            if server_config.get('enabled', False):
                print(f"      ✓ {name}")
    
    def validate_gitignore(self) -> None:
        """Validate .gitignore has Claude-specific entries."""
        print("\n" + "=" * 60)
        print("  Validating .gitignore")
        print("=" * 60)
        
        path = Path(".gitignore")
        
        if not path.exists():
            self.error(".gitignore not found")
            return
        
        try:
            # FIX: Explicitly use UTF-8 encoding
            content = path.read_text(encoding='utf-8')
        except UnicodeDecodeError:
            try:
                content = path.read_text(encoding='latin-1')
                self.warning(".gitignore has encoding issues.")
            except Exception as e:
                self.error(f"Cannot read .gitignore: {e}")
                return
        
        # Required patterns
        required = {
            '.claude/CLAUDE.local.md': 'Personal Claude configs',
            'REFACTOR_PROGRESS.md': 'Temporary progress files',
        }
        
        for pattern, description in required.items():
            if pattern in content:
                self.success(f"{description} properly ignored")
            else:
                self.warning(f"Missing .gitignore entry: {pattern} ({description})")
    
    def validate_skills(self) -> None:
        """Validate skills directory structure."""
        print("\n" + "=" * 60)
        print("  Validating Skills System")
        print("=" * 60)
        
        skills_dir = Path(".claude/skills")
        
        if not skills_dir.exists():
            self.error(".claude/skills directory not found")
            self.info_msg("Skills are required for workflows to function")
            return
        
        # Count skills
        skills = [d for d in skills_dir.iterdir() if d.is_dir()]
        
        if len(skills) == 0:
            self.error("No skills found in .claude/skills/")
            return
        
        print(f"   Skills installed: {len(skills)}")
        for skill in skills:
            print(f"      - {skill.name}")
            
            # Check for SKILL.md
            skill_md = skill / "SKILL.md"
            if not skill_md.exists():
                self.warning(f"Skill '{skill.name}' missing SKILL.md")
        
        self.success(f"Skills system configured ({len(skills)} skills)")
    
    def print_summary(self) -> int:
        """Print summary and return exit code."""
        print("\n" + "=" * 60)
        print("  Validation Summary")
        print("=" * 60)
        print()
        
        # Print all issues
        for error in self.errors:
            print(error)
        
        for warning in self.warnings:
            print(warning)
        
        for info in self.info:
            print(info)
        
        # Summary box
        print()
        if len(self.errors) == 0 and len(self.warnings) == 0:
            print(f"{GREEN}╔══════════════════════════════════════════════════════╗{NC}")
            print(f"{GREEN}║  🎉 PERFECT! All validations passed                 ║{NC}")
            print(f"{GREEN}╚══════════════════════════════════════════════════════╝{NC}")
            return 0
        elif len(self.errors) == 0:
            print(f"{YELLOW}╔══════════════════════════════════════════════════════╗{NC}")
            print(f"{YELLOW}║  ⚠️  WARNINGS - Configuration can be improved        ║{NC}")
            print(f"{YELLOW}╚══════════════════════════════════════════════════════╝{NC}")
            print()
            print(f"Warnings: {len(self.warnings)}")
            print(f"Info: {len(self.info)}")
            return 0
        else:
            print(f"{RED}╔══════════════════════════════════════════════════════╗{NC}")
            print(f"{RED}║  ❌ ERRORS - Fix before committing                   ║{NC}")
            print(f"{RED}╚══════════════════════════════════════════════════════╝{NC}")
            print()
            print(f"Errors: {len(self.errors)}")
            print(f"Warnings: {len(self.warnings)}")
            print(f"Info: {len(self.info)}")
            return 1


def main():
    """Main validation entry point."""
    print("╔══════════════════════════════════════════════════════╗")
    print("║   Claude Code Configuration Validator                ║")
    print("╚══════════════════════════════════════════════════════╝")
    
    validator = ConfigValidator()
    
    # Run all validations
    validator.validate_claude_md()
    validator.validate_settings_json()
    validator.validate_mcp_json()
    validator.validate_gitignore()
    validator.validate_skills()
    
    # Print summary and exit
    exit_code = validator.print_summary()
    sys.exit(exit_code)


if __name__ == '__main__':
    main()