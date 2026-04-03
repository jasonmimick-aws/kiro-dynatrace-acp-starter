# Kiro + Dynatrace Demo Outline (30 min)

## Opening (2 min)
- "Today I'll show how Kiro CLI connects to Dynatrace via MCP, learns new tools via Skills, and works in any editor via ACP"
- Show kiro.dev homepage briefly

## 1. Kiro CLI + Dynatrace MCP (8 min)

**Terminal:**
```bash
cd ~/work/dtclt-kiro
kiro-cli chat
```

**Show the MCP config:**
```bash
cat .kiro/settings/mcp.json
```
- Point out: just a URL + token, no local server needed

**Live queries:**
```
Show me open Dynatrace problems
```
```
Query error logs from the last hour, limit 5
```
```
What services is Dynatrace monitoring?
```

**Key message:** Natural language → DQL queries → real data. No context switching.

## 2. Skills — Teaching Kiro dtctl (5 min)

**Show the skill file:**
```bash
cat .kiro/skills/dtctl/SKILL.md | head -40
```
- Point out: plain markdown that teaches Kiro a new CLI tool

**Create a dashboard:**
```
Create a dashboard called "Demo Dashboard" showing error rate for my top service
```
- Kiro reads the skill → generates YAML → runs `dtctl apply`
- Show the dashboard in Dynatrace UI

**Key message:** Skills are how you extend Kiro. Markdown file = new capability.

## 3. ACP — Works Everywhere (8 min)

**Obsidian demo:**
- Open ~/work/test-vault2 in Obsidian
- Show our custom Kiro plugin (robot icon)
- Click it, send: "Show me open Dynatrace problems"
- Response streams right in Obsidian

**Key message:** Configure once (MCP + Skills), use everywhere. Same Dynatrace tools in terminal, Obsidian, Zed, JetBrains.

**Show the architecture:**
- Terminal/Obsidian/Zed → ACP (JSON-RPC) → Kiro CLI → MCP → Dynatrace
- One config, many clients

## 4. The Blog + Starter Repo (3 min)

- Show: https://builder.aws.com/content/3Bl5ti5j15Ahz2Z7EyToMqlapb0
- Show: https://github.com/jasonmimick-aws/kiro-dynatrace-acp-starter
- "Clone, set 2 env vars, kiro-cli chat — you're connected to Dynatrace"

## 5. Q&A (4 min)

---

## Pre-demo checklist
- [ ] `export DT_TENANT` and `DT_PLATFORM_TOKEN` are set
- [ ] `kiro-cli chat` works in terminal
- [ ] `dtctl auth whoami` works (re-login if expired: `dtctl auth login`)
- [ ] Obsidian open with test-vault2, Kiro plugin enabled
- [ ] Browser tab open to Dynatrace environment
- [ ] Browser tab open to builder.aws.com blog post
- [ ] Browser tab open to GitHub starter repo
