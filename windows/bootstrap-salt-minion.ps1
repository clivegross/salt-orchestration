# Salt Bootstrap Script for Windows
# Installs Salt minion with computer name as minion ID and configures master
# Usage: .\bootstrap-salt-minion.ps1 -Master <Master_IP_or_Hostname>

param(
    [Parameter(Mandatory=$true)]
    [string]$Master
)

# Set TLS 1.2 for secure downloads
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'

Write-Host "Starting Salt minion installation..." -ForegroundColor Green
Write-Host "Master: $Master" -ForegroundColor Yellow
Write-Host "Minion ID will be set to: $env:COMPUTERNAME" -ForegroundColor Yellow

# Download the bootstrap script
Write-Host "Downloading bootstrap script..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.ps1 -OutFile "$env:TEMP\bootstrap-salt.ps1"
    Write-Host "Bootstrap script downloaded successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to download bootstrap script: $_"
    exit 1
}

# Install Salt minion with computer name as minion ID
Write-Host "Installing Salt minion..." -ForegroundColor Cyan
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    & "$env:TEMP\bootstrap-salt.ps1" -Minion $env:COMPUTERNAME -Master $Master
    Write-Host "Salt minion installed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to install Salt minion: $_"
    exit 1
}

# Wait for installation to complete
Start-Sleep -Seconds 5

# Configure the master IP
Write-Host "Configuring master IP..." -ForegroundColor Cyan

# Find the Salt installation path
$possiblePaths = @(
    "C:\salt\conf\minion",
    "C:\Program Files\Salt Project\Salt\conf\minion",
    "C:\Program Files (x86)\Salt Project\Salt\conf\minion",
    "C:\ProgramData\Salt Project\Salt\conf\minion"
)

$minionConfigPath = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $minionConfigPath = $path
        Write-Host "Found minion config at: $path" -ForegroundColor Yellow
        break
    }
}

if ($minionConfigPath -and (Test-Path $minionConfigPath)) {
    try {
        # Read current config
        $config = Get-Content $minionConfigPath
        
        # Check if master line exists and update it, or add it
        $masterLineExists = $false
        $updatedConfig = @()
        
        foreach ($line in $config) {
            if ($line -match "^master:") {
                $updatedConfig += "master: $Master"
                $masterLineExists = $true
                Write-Host "Updated existing master configuration." -ForegroundColor Yellow
            }
            elseif ($line -match "^#master:") {
                $updatedConfig += "master: $Master"
                $masterLineExists = $true
                Write-Host "Uncommented and updated master configuration." -ForegroundColor Yellow
            }
            else {
                $updatedConfig += $line
            }
        }
        
        # If no master line was found, add it at the top
        if (-not $masterLineExists) {
            $updatedConfig = @("master: $Master") + $updatedConfig
            Write-Host "Added new master configuration." -ForegroundColor Yellow
        }
        
        # Write the updated config back
        $updatedConfig | Set-Content $minionConfigPath -Encoding UTF8
        Write-Host "Master configuration updated successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update minion configuration: $_"
        exit 1
    }
}
else {
    Write-Error "Minion configuration file not found in any of these locations:"
    $possiblePaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host "Please check your Salt installation." -ForegroundColor Yellow
    exit 1
}

# Restart the Salt minion service to apply changes
Write-Host "Restarting Salt minion service..." -ForegroundColor Cyan
try {
    Restart-Service salt-minion -Force
    Write-Host "Salt minion service restarted successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to restart Salt minion service: $_"
    exit 1
}

# Wait for service to fully start
Start-Sleep -Seconds 5

# Test the minion connection
Write-Host "Testing minion connection..." -ForegroundColor Cyan

# Find salt-call executable
$saltCallPaths = @(
    "C:\salt\salt-call.bat",
    "C:\Program Files\Salt Project\Salt\salt-call.bat",
    "C:\Program Files (x86)\Salt Project\Salt\salt-call.bat",
    "C:\ProgramData\Salt Project\Salt\salt-call.bat"
)

$saltCallPath = $null
foreach ($path in $saltCallPaths) {
    if (Test-Path $path) {
        $saltCallPath = $path
        break
    }
}

try {
    if ($saltCallPath) {
        $testResult = & $saltCallPath test.ping --timeout=10 2>&1
        if ($testResult -match "True") {
            Write-Host "SUCCESS: Minion can communicate with master!" -ForegroundColor Green
        }
        else {
            Write-Warning "Minion installed but may need key acceptance on master."
            Write-Host "Run this on the master to accept the key:" -ForegroundColor Yellow
            Write-Host "sudo salt-key -a $env:COMPUTERNAME" -ForegroundColor White
        }
    }
    else {
        Write-Warning "Could not find salt-call executable to test connection."
    }
}
catch {
    Write-Warning "Could not test connection immediately. This is normal for new installations."
    Write-Host "The minion key may need to be accepted on the master:" -ForegroundColor Yellow
    Write-Host "sudo salt-key -L" -ForegroundColor White
    Write-Host "sudo salt-key -a $env:COMPUTERNAME" -ForegroundColor White
}

Write-Host "`nInstallation Summary:" -ForegroundColor Magenta
Write-Host "- Salt minion installed: YES" -ForegroundColor White
Write-Host "- Minion ID: $env:COMPUTERNAME" -ForegroundColor White
Write-Host "- Master: $Master" -ForegroundColor White
Write-Host "- Service running: $(if ((Get-Service salt-minion).Status -eq 'Running') { 'YES' } else { 'NO' })" -ForegroundColor White

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. On the master ($Master), run: sudo salt-key -L" -ForegroundColor White
Write-Host "2. Accept this minion's key: sudo salt-key -a $env:COMPUTERNAME" -ForegroundColor White
Write-Host "3. Test connection: sudo salt '$env:COMPUTERNAME' test.ping" -ForegroundColor White

Write-Host "`nInstallation completed!" -ForegroundColor Green