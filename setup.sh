#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Kiro CLI + Dynatrace Quick Setup"
echo "===================================="
echo ""

# Check kiro-cli
if command -v kiro-cli >/dev/null 2>&1; then
  echo "✅ kiro-cli found at $(which kiro-cli)"
else
  echo "❌ kiro-cli not found — install from https://kiro.dev/downloads/"
  exit 1
fi

# Dynatrace tenant
echo ""
if [ -n "${DT_TENANT:-}" ]; then
  echo "✅ DT_TENANT=$DT_TENANT"
else
  read -rp "🔗 Dynatrace tenant ID (e.g., abc12345): " DT_TENANT_INPUT
  echo ""
  echo "   Add to your shell profile:"
  echo "   export DT_TENANT=\"$DT_TENANT_INPUT\""
fi

# Platform token
if [ -n "${DT_PLATFORM_TOKEN:-}" ]; then
  echo "✅ DT_PLATFORM_TOKEN is set"
else
  echo ""
  echo "📋 You need a Dynatrace Platform Token."
  echo "   1. Go to https://myaccount.dynatrace.com/platformTokens"
  echo "   2. Create a token with scopes:"
  echo "      mcp-gateway:servers:invoke, mcp-gateway:servers:read,"
  echo "      storage:*:read, davis-copilot:*:execute,"
  echo "      automation:workflows:read, document:documents:read"
  echo "   3. export DT_PLATFORM_TOKEN=\"dt0s16....\""
fi

# MCP config
echo ""
echo "📁 MCP configuration..."
if [ -f .kiro/settings/mcp.json ]; then
  echo "   ✅ .kiro/settings/mcp.json exists (remote MCP server)"
else
  echo "   ⚠️  .kiro/settings/mcp.json not found — check the repo"
fi

# dtctl (optional)
echo ""
if command -v dtctl >/dev/null 2>&1; then
  echo "✅ dtctl found at $(which dtctl)"
else
  echo "📦 dtctl (optional) — adds dashboard/workflow/SLO management"
  read -rp "   Install? (y/N): " INSTALL_DTCTL
  if [[ "$INSTALL_DTCTL" =~ ^[Yy]$ ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install dynatrace-oss/tap/dtctl
      echo "   ✅ dtctl installed"
      echo "   Run: dtctl auth login --context my-env --environment \"https://${DT_TENANT_INPUT:-YOUR-ENV-ID}.apps.dynatrace.com\""
      echo "   Run: dtctl skills install --cross-client"
    else
      echo "   ⚠️  Homebrew not found. See: https://github.com/dynatrace-oss/dtctl"
    fi
  fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. export DT_TENANT=\"your-env-id\""
echo "  2. export DT_PLATFORM_TOKEN=\"dt0s16....\""
echo "  3. kiro-cli chat"
echo ""
echo "Or use Kiro in Obsidian/JetBrains/Zed — see README.md for ACP setup."
echo ""
