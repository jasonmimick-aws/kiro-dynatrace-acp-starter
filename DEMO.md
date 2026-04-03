# Kiro + Dynatrace Demo Outline (30 min)

## Opening (2 min)
- "Today I'll show how Kiro CLI connects to Dynatrace via MCP, learns new tools via Skills, and works in any editor via ACP"
- Show kiro.dev homepage briefly

## 1. Kiro CLI + Dynatrace MCP (7 min)

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

## 3. ACP — Obsidian Scenario 1: Incident Correlation (7 min)

**Setup:** Open ~/work/test-vault2 in Obsidian. Pre-created note "Incident Report - 2026-04-02" is open.

**Show the note** — raw incident notes from a meeting:
- Timestamp, affected service, symptoms, who reported it
- Incomplete — missing root cause, timeline, impact

**Click the Kiro robot icon, then ask:**
```
Read my "Incident Report - 2026-04-02" note. Query Dynatrace for problems and errors during that timeframe. Correlate what you find with my notes and give me an enhanced incident report with root cause, affected entities, and timeline.
```

- Kiro reads the note → queries Dynatrace problems + logs → returns enriched report
- Copy the response back into the note

**Key message:** Your messy meeting notes + live Dynatrace data = complete incident report. All from your note-taking app.

## 4. ACP — Obsidian Scenario 2: Problem Report + Dashboard (7 min)

**Start fresh in Obsidian, ask Kiro:**
```
Query Dynatrace for all open problems right now. Create a problem report as a new note with severity, affected services, root cause analysis, and recommended actions.
```

- Kiro queries Dynatrace → generates a structured problem report
- Copy into a new Obsidian note

**Then ask:**
```
Based on those problems, create a Dynatrace dashboard called "Active Issues - April 2026" with tiles showing error rates, problem count, and affected services.
```

- Kiro uses dtctl skill → generates dashboard YAML → deploys it
- Switch to browser → show the dashboard live in Dynatrace

**Key message:** From note-taking app → queried live data → created a production dashboard. Zero context switching. All from Obsidian.

## 5. The Blog + Starter Repo (2 min)

- Show: https://builder.aws.com/content/3Bl5ti5j15Ahz2Z7EyToMqlapb0
- Show: https://github.com/jasonmimick-aws/kiro-dynatrace-acp-starter
- "Clone, set 2 env vars, kiro-cli chat — you're connected to Dynatrace"
- Mention the custom Obsidian plugin we built (obsidian-kiro)

## 6. Q&A (2 min)

---

## Pre-demo checklist
- [ ] `export DT_TENANT` and `DT_PLATFORM_TOKEN` are set
- [ ] `kiro-cli chat` works in terminal
- [ ] `dtctl auth whoami` works (re-login if expired: `dtctl auth login`)
- [ ] Obsidian open with test-vault2, Kiro plugin enabled
- [ ] "Incident Report - 2026-04-02.md" note exists in test-vault2
- [ ] Browser tab open to Dynatrace environment
- [ ] Browser tab open to builder.aws.com blog post
- [ ] Browser tab open to GitHub starter repo
