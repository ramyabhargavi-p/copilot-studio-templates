# setup-agent-dev.ps1
# Copilot Studio Agent Setup Automation Script (Windows)
# 
# This script automates the setup of a new Copilot Studio agent development environment.
# It checks prerequisites, installs missing tools, authenticates, creates folder structure,
# and prepares your first agent for deployment.
#
# Usage: .\setup-agent-dev.ps1 -AgentName "my_first_agent" -DisplayName "My First Agent"
#
# Parameters:
#   -AgentName      Schema name (lowercase, no spaces) - e.g., "my_first_agent"
#   -DisplayName    Display name (can have spaces) - e.g., "My First Agent"
#   -SystemPrompt   What your agent does (optional, can edit later)

param(
    [Parameter(Mandatory=$true)]
    [string]$AgentName,
    
    [Parameter(Mandatory=$true)]
    [string]$DisplayName,
    
    [Parameter(Mandatory=$false)]
    [string]$SystemPrompt = "I am a helpful assistant that answers questions and assists users."
)

# Color output
$colors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Cyan = "Cyan"
}

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $statusColor = switch($Status) {
        "SUCCESS" { $colors.Green }
        "ERROR" { $colors.Red }
        "WARNING" { $colors.Yellow }
        default { $colors.Cyan }
    }
    Write-Host "[$timestamp] $Status : $Message" -ForegroundColor $statusColor
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# ==============================================================================
# PHASE 1: CHECK & INSTALL PAC CLI
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 1: Check & Install pac CLI" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (Test-Command "pac") {
    Write-Status "pac CLI found" "SUCCESS"
    $pacVersion = pac --version | Select-Object -First 1
    Write-Status "Version: $pacVersion" "SUCCESS"
} else {
    Write-Status "pac CLI not found. Installing..." "WARNING"
    Write-Host "Running: winget install Microsoft.PowerAppsCLI`n"
    winget install Microsoft.PowerAppsCLI
    
    if (Test-Command "pac") {
        Write-Status "pac CLI installed successfully" "SUCCESS"
    } else {
        Write-Status "FAILED: pac CLI installation failed. Please install manually." "ERROR"
        Write-Host "Manual install: https://learn.microsoft.com/power-platform/developer/cli/introduction`n"
        exit 1
    }
}

# ==============================================================================
# PHASE 2: CHECK VS CODE & EXTENSIONS
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 2: Check VS Code & Extensions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (Test-Command "code") {
    Write-Status "VS Code found" "SUCCESS"
} else {
    Write-Status "WARNING: VS Code not found. You need to install it manually." "WARNING"
    Write-Host "Download from: https://code.visualstudio.com`n"
}

Write-Status "Verifying Copilot Studio extension..." "INFO"
Write-Host "Installing VS Code extensions...`n"

# Install extensions
code --install-extension ms-powerplatform.powerplatform-vscode-extension 2>$null
code --install-extension redhat.vscode-yaml 2>$null
code --install-extension eamodio.gitlens 2>$null
code --install-extension oderwat.indent-rainbow 2>$null

Write-Status "VS Code extensions installed" "SUCCESS"

# ==============================================================================
# PHASE 3: TEST AUTHENTICATION
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 3: Test Authentication" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Status "Checking pac authentication..." "INFO"
$authTest = pac env who 2>&1
if ($authTest -like "*Connected*") {
    Write-Status "Authentication successful" "SUCCESS"
    Write-Host "$authTest`n"
} else {
    Write-Status "Not authenticated or connection failed" "WARNING"
    Write-Host "Running: pac auth create`n"
    pac auth create
    
    $authTest = pac env who 2>&1
    if ($authTest -like "*Connected*") {
        Write-Status "Authentication successful" "SUCCESS"
        Write-Host "$authTest`n"
    } else {
        Write-Status "FAILED: Authentication failed. Check your credentials." "ERROR"
        exit 1
    }
}

# ==============================================================================
# PHASE 4: CREATE FOLDER STRUCTURE
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 4: Create Folder Structure" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$agentPath = "agents\$AgentName"

if (Test-Path $agentPath) {
    Write-Status "Agent folder already exists: $agentPath" "WARNING"
    $confirm = Read-Host "Overwrite existing agent? (y/N)"
    if ($confirm -ne "y") {
        Write-Status "Cancelled" "INFO"
        exit 0
    }
    Remove-Item $agentPath -Recurse -Force
}

# Create folder
New-Item -ItemType Directory -Path $agentPath -Force | Out-Null
Write-Status "Created agent folder: $agentPath" "SUCCESS"

# ==============================================================================
# PHASE 5: COPY BASE TEMPLATE
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 5: Copy Base Template" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if (-not (Test-Path "base")) {
    Write-Status "ERROR: 'base' folder not found. Are you in the copilot-studio-templates repo?" "ERROR"
    Write-Host "Make sure you are in the repository root directory with 'base/' folder.`n"
    exit 1
}

Write-Status "Copying base template files..." "INFO"
Copy-Item -Path "base\*" -Destination $agentPath -Recurse -Force
Write-Status "Base template copied" "SUCCESS"

# ==============================================================================
# PHASE 6: REPLACE PLACEHOLDERS
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 6: Replace Placeholders" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Status "Replacing placeholders..." "INFO"

# Files to update
$filesToUpdate = @(
    @{File = "$agentPath\agent.mcs.yml"; Find = "<AgentName>"; Replace = $AgentName },
    @{File = "$agentPath\agent.mcs.yml"; Find = "<Agent Display Name>"; Replace = $DisplayName },
    @{File = "$agentPath\agent.mcs.yml"; Find = "<SYSTEM_PROMPT>"; Replace = $SystemPrompt },
    @{File = "$agentPath\settings.mcs.yml"; Find = "<agent_schema_name>"; Replace = $AgentName },
    @{File = "$agentPath\Fallback.topic.mcs.yml"; Find = "<AGENT_SCHEMA>"; Replace = $AgentName }
)

foreach ($fileConfig in $filesToUpdate) {
    $filePath = $fileConfig.File
    $find = $fileConfig.Find
    $replace = $fileConfig.Replace
    
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $newContent = $content -replace [regex]::Escape($find), $replace
        Set-Content $filePath $newContent -NoNewline
        Write-Status "Replaced '$find' in $(Split-Path -Leaf $filePath)" "SUCCESS"
    } else {
        Write-Status "ERROR: File not found: $filePath" "ERROR"
    }
}

# ==============================================================================
# PHASE 7: GENERATE UNIQUE NODE IDS
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 7: Generate Unique Node IDs" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Status "Note: Open files in VS Code and save to auto-generate node IDs" "INFO"
Write-Status "VS Code Copilot Studio extension will replace _REPLACE automatically" "INFO"
Write-Host "`n"

# ==============================================================================
# PHASE 8: VERIFICATION
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 8: Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$verifyFilePath = "$agentPath\agent.mcs.yml"
$verifyContent = Get-Content $verifyFilePath

if ($verifyContent -match $AgentName) {
    Write-Status "Agent name configured correctly" "SUCCESS"
} else {
    Write-Status "WARNING: Agent name may not be configured correctly" "WARNING"
}

# Check for remaining placeholders
$placeholderCheck = Get-ChildItem $agentPath -Recurse -Include "*.yml" | 
    Select-String "<.*>" 2>$null

if ($placeholderCheck) {
    Write-Status "WARNING: Found remaining placeholders" "WARNING"
    Write-Host "Run the following in VS Code to auto-replace node IDs:`n"
    Write-Host "  Ctrl+Shift+F → search: _REPLACE`n"
} else {
    Write-Status "All placeholders replaced" "SUCCESS"
}

# ==============================================================================
# PHASE 9: OUTPUT SUMMARY
# ==============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✓ SETUP COMPLETE" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Agent Created: $agentPath`n"

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open in VS Code:"
Write-Host "     code $agentPath`n"
Write-Host "  2. Verify configuration (should see no red squiggles)"
Write-Host "  3. Save files (Ctrl+S) to auto-generate node IDs`n"
Write-Host "  4. Deploy to cloud:"
Write-Host "     Ctrl+Shift+P → 'Copilot Studio: Apply Changes'`n"
Write-Host "  5. Verify in Copilot Studio:"
Write-Host "     https://make.microsoft.com`n"

Write-Host "Quick Commands:" -ForegroundColor Cyan
Write-Host "  Check environment: pac env who"
Write-Host "  List agents: pac copilot list"
Write-Host "  Open Copilot Studio: start https://make.microsoft.com`n"

Write-Status "Setup script complete!" "SUCCESS"
Write-Host "`n"
