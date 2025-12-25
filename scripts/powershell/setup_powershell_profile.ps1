# PowerShell Profile Setup Script for Claude Code Playbook
# Automates execution policy, profile directory creation, and backups

Write-Host "=== Claude Code PowerShell Profile Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check and set execution policy
Write-Host "1. Checking execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq 'Restricted' -or $policy -eq 'Undefined') {
    Write-Host "   Current policy: $policy" -ForegroundColor Yellow
    Write-Host "   Setting execution policy to RemoteSigned..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "   ✓ Execution policy updated to RemoteSigned" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Failed to set execution policy: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✓ Execution policy already set: $policy" -ForegroundColor Green
}
Write-Host ""

# Step 2: Create profile directory
Write-Host "2. Checking profile directory..." -ForegroundColor Yellow
$ProfileDir = Split-Path $PROFILE
Write-Host "   Profile location: $PROFILE" -ForegroundColor Cyan
if (-not (Test-Path $ProfileDir)) {
    Write-Host "   Creating profile directory..." -ForegroundColor Yellow
    try {
        New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
        Write-Host "   ✓ Profile directory created at $ProfileDir" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Failed to create directory: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✓ Profile directory exists" -ForegroundColor Green
}
Write-Host ""

# Step 3: Backup existing profile
Write-Host "3. Checking for existing profile..." -ForegroundColor Yellow
if (Test-Path $PROFILE) {
    $BackupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "   Existing profile found. Creating backup..." -ForegroundColor Yellow
    try {
        Copy-Item $PROFILE $BackupPath
        Write-Host "   ✓ Backup created: $BackupPath" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠ Backup failed: $_" -ForegroundColor Yellow
        Write-Host "   Continuing anyway..." -ForegroundColor Yellow
    }
} else {
    Write-Host "   No existing profile found" -ForegroundColor Gray
}
Write-Host ""

# Step 4: Ready for profile creation
Write-Host "4. Setup complete!" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "=== Setup Summary ===" -ForegroundColor Cyan
Write-Host "Profile location: $PROFILE"
Write-Host "Execution policy: $(Get-ExecutionPolicy -Scope CurrentUser)"
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. The PowerShell profile will be created by Claude"
Write-Host "2. After profile is created, reload: . `$PROFILE"
Write-Host "3. Verify setup: cchealth"
Write-Host "4. See available commands: Get-Alias | Where-Object { `$_.Name -like 'cc*' }"
Write-Host ""
