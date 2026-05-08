#!/bin/bash
# setup-agent-dev.sh
# Copilot Studio Agent Setup Automation Script (macOS / Linux)
#
# This script automates the setup of a new Copilot Studio agent development environment.
# It checks prerequisites, installs missing tools, authenticates, creates folder structure,
# and prepares your first agent for deployment.
#
# Usage: ./setup-agent-dev.sh -a my_first_agent -d "My First Agent"
#
# Options:
#   -a, --agent-name    Schema name (lowercase, no spaces) - e.g., my_first_agent
#   -d, --display-name  Display name (can have spaces) - e.g., "My First Agent"
#   -p, --prompt        System prompt (optional)
#   -h, --help          Show this help message

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
SYSTEM_PROMPT="I am a helpful assistant that answers questions and assists users."

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--agent-name)
            AGENT_NAME="$2"
            shift 2
            ;;
        -d|--display-name)
            DISPLAY_NAME="$2"
            shift 2
            ;;
        -p|--prompt)
            SYSTEM_PROMPT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Copilot Studio Agent Setup Script"
            echo "Usage: ./setup-agent-dev.sh -a <agent-name> -d <display-name>"
            echo ""
            echo "Options:"
            echo "  -a, --agent-name    Schema name (lowercase, no spaces)"
            echo "  -d, --display-name  Display name (can have spaces)"
            echo "  -p, --prompt        System prompt (optional)"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$AGENT_NAME" ] || [ -z "$DISPLAY_NAME" ]; then
    echo -e "${RED}Error: Both --agent-name and --display-name are required${NC}"
    echo "Usage: ./setup-agent-dev.sh -a my_first_agent -d 'My First Agent'"
    exit 1
fi

write_status() {
    local message=$1
    local status=${2:-INFO}
    local timestamp=$(date +%H:%M:%S)
    
    case $status in
        SUCCESS)
            echo -e "[$timestamp] ${GREEN}$status${NC} : $message"
            ;;
        ERROR)
            echo -e "[$timestamp] ${RED}$status${NC} : $message"
            ;;
        WARNING)
            echo -e "[$timestamp] ${YELLOW}$status${NC} : $message"
            ;;
        *)
            echo -e "[$timestamp] ${CYAN}$status${NC} : $message"
            ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ==============================================================================
# PHASE 1: CHECK & INSTALL PAC CLI
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 1: Check & Install pac CLI"
echo "========================================${NC}"
echo ""

if command_exists pac; then
    write_status "pac CLI found" "SUCCESS"
    PAC_VERSION=$(pac --version 2>/dev/null | head -1)
    write_status "Version: $PAC_VERSION" "SUCCESS"
else
    write_status "pac CLI not found. Installing..." "WARNING"
    echo "Running: dotnet tool install --global Microsoft.PowerApps.CLI.Tool"
    echo ""
    
    if command_exists dotnet; then
        dotnet tool install --global Microsoft.PowerApps.CLI.Tool
        
        # Update PATH to include dotnet tools
        export PATH="$PATH:$HOME/.dotnet/tools"
        
        if command_exists pac; then
            write_status "pac CLI installed successfully" "SUCCESS"
        else
            write_status "FAILED: pac CLI installation failed." "ERROR"
            echo "Please install manually: https://learn.microsoft.com/power-platform/developer/cli/introduction"
            exit 1
        fi
    else
        write_status "ERROR: dotnet is not installed" "ERROR"
        echo "Please install .NET: https://dotnet.microsoft.com/download"
        exit 1
    fi
fi

# ==============================================================================
# PHASE 2: CHECK VS CODE
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 2: Check VS Code"
echo "========================================${NC}"
echo ""

if command_exists code; then
    write_status "VS Code found" "SUCCESS"
else
    write_status "WARNING: VS Code not found. You need to install it manually." "WARNING"
    echo "Download from: https://code.visualstudio.com"
    echo ""
fi

write_status "Installing VS Code extensions..." "INFO"
code --install-extension ms-powerplatform.powerplatform-vscode-extension 2>/dev/null || true
code --install-extension redhat.vscode-yaml 2>/dev/null || true
code --install-extension eamodio.gitlens 2>/dev/null || true
code --install-extension oderwat.indent-rainbow 2>/dev/null || true

write_status "VS Code extensions installed" "SUCCESS"

# ==============================================================================
# PHASE 3: TEST AUTHENTICATION
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 3: Test Authentication"
echo "========================================${NC}"
echo ""

write_status "Checking pac authentication..." "INFO"
if AUTH_TEST=$(pac env who 2>&1) && echo "$AUTH_TEST" | grep -q "Connected"; then
    write_status "Authentication successful" "SUCCESS"
    echo "$AUTH_TEST"
    echo ""
else
    write_status "Not authenticated or connection failed" "WARNING"
    echo "Running: pac auth create"
    echo ""
    pac auth create
    echo ""
    
    if AUTH_TEST=$(pac env who 2>&1) && echo "$AUTH_TEST" | grep -q "Connected"; then
        write_status "Authentication successful" "SUCCESS"
        echo "$AUTH_TEST"
        echo ""
    else
        write_status "FAILED: Authentication failed. Check your credentials." "ERROR"
        exit 1
    fi
fi

# ==============================================================================
# PHASE 4: CREATE FOLDER STRUCTURE
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 4: Create Folder Structure"
echo "========================================${NC}"
echo ""

AGENT_PATH="agents/$AGENT_NAME"

if [ -d "$AGENT_PATH" ]; then
    write_status "Agent folder already exists: $AGENT_PATH" "WARNING"
    read -p "Overwrite existing agent? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        write_status "Cancelled" "INFO"
        exit 0
    fi
    rm -rf "$AGENT_PATH"
fi

mkdir -p "$AGENT_PATH"
write_status "Created agent folder: $AGENT_PATH" "SUCCESS"

# ==============================================================================
# PHASE 5: COPY BASE TEMPLATE
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 5: Copy Base Template"
echo "========================================${NC}"
echo ""

if [ ! -d "base" ]; then
    write_status "ERROR: 'base' folder not found. Are you in the copilot-studio-templates repo?" "ERROR"
    echo "Make sure you are in the repository root directory with 'base/' folder."
    echo ""
    exit 1
fi

write_status "Copying base template files..." "INFO"
cp -r base/* "$AGENT_PATH/"
write_status "Base template copied" "SUCCESS"

# ==============================================================================
# PHASE 6: REPLACE PLACEHOLDERS
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 6: Replace Placeholders"
echo "========================================${NC}"
echo ""

write_status "Replacing placeholders..." "INFO"

# Determine sed command (macOS uses -i '' while Linux uses -i)
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_CMD="sed -i ''"
else
    SED_CMD="sed -i"
fi

# Replace in agent.mcs.yml
$SED_CMD "s/<AgentName>/$AGENT_NAME/g" "$AGENT_PATH/agent.mcs.yml"
write_status "Replaced '<AgentName>' in agent.mcs.yml" "SUCCESS"

$SED_CMD "s/<Agent Display Name>/$DISPLAY_NAME/g" "$AGENT_PATH/agent.mcs.yml"
write_status "Replaced '<Agent Display Name>' in agent.mcs.yml" "SUCCESS"

$SED_CMD "s/<SYSTEM_PROMPT>/$SYSTEM_PROMPT/g" "$AGENT_PATH/agent.mcs.yml"
write_status "Replaced '<SYSTEM_PROMPT>' in agent.mcs.yml" "SUCCESS"

# Replace in settings.mcs.yml
$SED_CMD "s/<agent_schema_name>/$AGENT_NAME/g" "$AGENT_PATH/settings.mcs.yml"
write_status "Replaced '<agent_schema_name>' in settings.mcs.yml" "SUCCESS"

# Replace in Fallback.topic.mcs.yml
$SED_CMD "s/<AGENT_SCHEMA>/$AGENT_NAME/g" "$AGENT_PATH/Fallback.topic.mcs.yml"
write_status "Replaced '<AGENT_SCHEMA>' in Fallback.topic.mcs.yml" "SUCCESS"

# ==============================================================================
# PHASE 7: GENERATE UNIQUE NODE IDS
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 7: Generate Unique Node IDs"
echo "========================================${NC}"
echo ""

write_status "Note: Open files in VS Code and save to auto-generate node IDs" "INFO"
write_status "VS Code Copilot Studio extension will replace _REPLACE automatically" "INFO"
echo ""

# ==============================================================================
# PHASE 8: VERIFICATION
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo "Phase 8: Verification"
echo "========================================${NC}"
echo ""

if grep -q "$AGENT_NAME" "$AGENT_PATH/agent.mcs.yml"; then
    write_status "Agent name configured correctly" "SUCCESS"
else
    write_status "WARNING: Agent name may not be configured correctly" "WARNING"
fi

# Check for remaining placeholders
if grep -r "<.*>" "$AGENT_PATH" 2>/dev/null | grep -qv "Binary"; then
    write_status "WARNING: Found remaining placeholders" "WARNING"
    echo "Run the following in VS Code to auto-replace node IDs:"
    echo ""
    echo "  Ctrl+Shift+F → search: _REPLACE"
    echo ""
else
    write_status "All placeholders replaced" "SUCCESS"
fi

# ==============================================================================
# PHASE 9: OUTPUT SUMMARY
# ==============================================================================
echo ""
echo -e "${CYAN}========================================"
echo -e "${GREEN}✓ SETUP COMPLETE${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "Agent Created: $AGENT_PATH"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Open in VS Code:"
echo "     code $AGENT_PATH"
echo ""
echo "  2. Verify configuration (should see no red squiggles)"
echo "  3. Save files (Ctrl+S) to auto-generate node IDs"
echo ""
echo "  4. Deploy to cloud:"
echo "     Ctrl+Shift+P → 'Copilot Studio: Apply Changes'"
echo ""
echo "  5. Verify in Copilot Studio:"
echo "     https://make.microsoft.com"
echo ""

echo -e "${CYAN}Quick Commands:${NC}"
echo "  Check environment: pac env who"
echo "  List agents: pac copilot list"
echo "  Open Copilot Studio: open https://make.microsoft.com"
echo ""

write_status "Setup script complete!" "SUCCESS"
echo ""
