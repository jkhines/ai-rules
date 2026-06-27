#!/bin/bash
# One-time setup for this repository
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$REPO_DIR/.githooks/pre-commit" "$REPO_DIR/install.sh" "$REPO_DIR/mcp.sh" "$REPO_DIR/setup.sh" "$REPO_DIR/scripts/open-google-chrome-cdp.sh"
git config core.hooksPath .githooks
echo "Git hooks configured."

