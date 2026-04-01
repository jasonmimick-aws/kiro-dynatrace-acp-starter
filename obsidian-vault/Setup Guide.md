# Setup Guide

## 1. Install the Agent Client Plugin

1. Open Obsidian Settings → **Community Plugins** → **Turn on community plugins**
2. Click **Browse** → search for **BRAT** → Install and Enable it
3. Go to **Settings → BRAT → Add Beta Plugin**
4. Paste: `https://github.com/RAIT-09/obsidian-agent-client`
5. Go back to **Community Plugins** → Enable **Agent Client**

## 2. Configure Kiro as Your Agent

1. Go to **Settings → Agent Client**
2. Scroll to **Custom Agents** → Click **Add custom agent**
3. Fill in:

| Field | Value |
|-------|-------|
| Agent ID | `kiro-cli` |
| Display name | `Kiro` |
| Path | `/Users/mimjasov/.local/bin/kiro-cli` |
| Arguments | `acp` |

That's it. Kiro automatically picks up your Dynatrace MCP config from `~/.kiro/settings/mcp.json` — no need to duplicate tokens or environment variables here.

## 3. Start Chatting

1. Click the **robot icon** in the left ribbon (or Cmd+P → "Open agent chat")
2. Select **Kiro** from the agent dropdown
3. Send `/tools trust-all` as your first message — this lets Kiro run tools without asking for approval each time
4. Try: "Show me open Dynatrace problems"

## How It Works

```
Obsidian ──ACP──► kiro-cli acp ──MCP (HTTPS)──► Dynatrace Remote MCP Server
                               ──shell──► dtctl ──► Dynatrace Platform
                               ──shell──► aws cli ──► AWS
```

Kiro runs as a local ACP agent. Obsidian communicates with it over stdin/stdout using JSON-RPC. Your existing `~/.kiro/settings/mcp.json` provides the Dynatrace connection — configure once, use everywhere.

## 4. Optional: Install dtctl

dtctl adds dashboard/workflow/SLO management as code.

```bash
brew install dynatrace-oss/tap/dtctl
dtctl auth login --context my-env --environment "https://hgd83841.apps.dynatrace.com"
dtctl doctor
dtctl skills install --cross-client
```

## What Can You Ask?

| Ask this... | Kiro uses... |
|-------------|-------------|
| "Show me error logs from the last hour" | MCP (remote) |
| "Are there open problems?" | MCP (remote) |
| "Ask Davis what caused this" | MCP (remote) |
| "Create a dashboard for checkout-service" | dtctl (shell) |
| "Pull that dashboard as YAML" | dtctl (shell) |
| "Check my ECS tasks in us-west-2" | AWS CLI (shell) |
