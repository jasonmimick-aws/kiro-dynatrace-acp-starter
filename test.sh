#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="kiro-dt-test"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- resolve DT creds from ~/.kiro/settings/mcp.json if not set ----------
if [ -z "${DT_PLATFORM_TOKEN:-}" ] || [ -z "${DT_TENANT:-}" ]; then
  MCP_FILE="$HOME/.kiro/settings/mcp.json"
  if [ -f "$MCP_FILE" ]; then
    # Try the power config first, then top-level
    TOKEN=$(jq -r '
      (.powers.mcpServers // {} | to_entries[] | select(.value.url? // "" | contains("dynatrace")) | .value.headers.Authorization) //
      (.mcpServers // {} | to_entries[] | select(.value.url? // "" | contains("dynatrace")) | .value.headers.Authorization) //
      empty' "$MCP_FILE" 2>/dev/null | head -1 | sed 's/^Bearer //')
    TENANT=$(jq -r '
      (.powers.mcpServers // {} | to_entries[] | select(.value.url? // "" | contains("dynatrace")) | .value.url) //
      (.mcpServers // {} | to_entries[] | select(.value.url? // "" | contains("dynatrace")) | .value.url) //
      empty' "$MCP_FILE" 2>/dev/null | head -1 | sed -E 's|https://([^.]+)\..*|\1|')

    [ -z "${DT_PLATFORM_TOKEN:-}" ] && [ -n "${TOKEN:-}" ] && export DT_PLATFORM_TOKEN="$TOKEN" && echo "📋 Read DT_PLATFORM_TOKEN from $MCP_FILE"
    [ -z "${DT_TENANT:-}" ] && [ -n "${TENANT:-}" ] && export DT_TENANT="$TENANT" && echo "📋 Read DT_TENANT=$DT_TENANT from $MCP_FILE"
  fi
fi

if [ -z "${DT_TENANT:-}" ] || [ -z "${DT_PLATFORM_TOKEN:-}" ]; then
  echo "❌ Could not resolve DT_TENANT and DT_PLATFORM_TOKEN."
  echo "   Either set them as env vars or ensure ~/.kiro/settings/mcp.json has a Dynatrace config."
  exit 1
fi

if [ ! -d "$HOME/.kiro" ]; then
  echo "❌ ~/.kiro not found. Run 'kiro-cli login' on your Mac first."
  exit 1
fi

# ---------- build ----------
echo "🔨 Building test container..."
docker build --platform linux/amd64 -t "$IMAGE_NAME" "$SCRIPT_DIR"

# ---------- run modes ----------
MODE="${1:-shell}"

case "$MODE" in
  shell)
    echo "🐚 Dropping into test container..."
    echo "   Try: kiro-cli chat"
    echo ""
    docker run -it --platform linux/amd64 \
      -v "$HOME/.aws:/root/.aws:ro" \
      -v "$HOME/.kiro:/root/.kiro" \
      -e DT_TENANT="$DT_TENANT" \
      -e DT_PLATFORM_TOKEN="$DT_PLATFORM_TOKEN" \
      "$IMAGE_NAME"
    ;;

  smoke)
    echo "🧪 Running smoke tests..."
    docker run --platform linux/amd64 \
      -v "$HOME/.aws:/root/.aws:ro" \
      -v "$HOME/.kiro:/root/.kiro" \
      -e DT_TENANT="$DT_TENANT" \
      -e DT_PLATFORM_TOKEN="$DT_PLATFORM_TOKEN" \
      "$IMAGE_NAME" \
      -c '
set -e
echo "=== T0: Tool versions ==="
echo -n "kiro-cli: "; kiro-cli --version 2>/dev/null || echo "NOT FOUND"
echo -n "node:     "; node --version
echo -n "aws:      "; aws --version
echo -n "dtctl:    "; dtctl version 2>/dev/null || echo "NOT FOUND"
echo ""

echo "=== T1: MCP config present ==="
cat /workspace/.kiro/settings/mcp.json
echo ""

echo "=== T2: Kiro auth tokens ==="
if [ -f /root/.kiro/auth.json ] || [ -d /root/.kiro/sessions ]; then
  echo "✅ Kiro auth data found"
else
  echo "⚠️  No auth data — run kiro-cli login on host first"
fi

echo "=== T3: AWS credentials ==="
aws sts get-caller-identity --no-cli-pager 2>/dev/null && echo "✅ AWS OK" || echo "⚠️  AWS not configured"

echo "=== T4: Dynatrace MCP endpoint reachable ==="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $DT_PLATFORM_TOKEN" \
  "https://${DT_TENANT}.apps.dynatrace.com/platform-reserved/mcp-gateway/v0.1/servers/dynatrace-mcp/mcp")
if [ "$HTTP_CODE" = "405" ] || [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Dynatrace MCP gateway reachable (HTTP $HTTP_CODE)"
else
  echo "❌ Dynatrace MCP gateway returned HTTP $HTTP_CODE"
fi

echo ""
echo "=== Smoke tests complete ==="
echo "Run ./test.sh shell to drop in and test kiro-cli chat interactively."
'
    ;;

  *)
    echo "Usage: ./test.sh [shell|smoke]"
    echo "  shell  — interactive bash in the container (default)"
    echo "  smoke  — run automated preflight checks"
    exit 1
    ;;
esac
