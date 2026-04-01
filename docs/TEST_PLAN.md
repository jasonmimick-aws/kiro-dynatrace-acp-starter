# Test Plan: kiro-dynatrace-acp-starter

## Prerequisites Checklist

- [ ] Kiro CLI installed (`which kiro-cli`)
- [ ] Dynatrace SaaS environment accessible
- [ ] Platform token created with MCP scopes (`mcp-gateway:servers:invoke`, `mcp-gateway:servers:read`, `storage:*:read`, `davis-copilot:*:execute`)
- [ ] `DT_TENANT` and `DT_PLATFORM_TOKEN` env vars set
- [ ] AWS CLI configured (for AWS scenarios)
- [ ] dtctl installed and authenticated (for resource management scenarios)
- [ ] Obsidian installed (for ACP/Obsidian scenarios)

---

## Phase 1: MCP Connection (must pass before anything else)

### T1.1 — Remote MCP server connects
```bash
kiro-cli chat
> /mcp
```
Expected: Dynatrace MCP server shows as connected with available tools listed.

### T1.2 — Basic DQL query
```
You: Show me logs from the last 10 minutes, limit 5
```
Expected: Kiro calls `execute_dql` or `generate_dql_from_natural_language`, returns log entries.

### T1.3 — Token auth failure (negative test)
Set `DT_PLATFORM_TOKEN` to an invalid value, start `kiro-cli chat`.
Expected: MCP server fails to connect with an auth error, Kiro reports the issue.

### T1.4 — Local MCP server fallback
Rename `mcp.local.json` → `mcp.json`, set `DT_ENVIRONMENT`, start `kiro-cli chat`.
Expected: Local server starts, browser OAuth flow triggers, tools available after auth.

---

## Phase 2: MCP Tools (query & investigate)

### T2.1 — List problems
```
You: Are there any open problems in my environment?
```
Expected: Returns problem list (or "no open problems"). No errors.

### T2.2 — Natural language to DQL
```
You: Show me error logs from the last hour for any service containing "checkout"
```
Expected: Kiro generates a DQL query with appropriate filters, executes it, returns results.

### T2.3 — Entity discovery
```
You: Find all services Dynatrace monitors that contain "order" in the name
```
Expected: Returns entity list with names, IDs, and health state.

### T2.4 — Davis AI
```
You: Ask Davis what the most impactful problem in my environment is right now
```
Expected: Kiro calls `chat_with_davis_copilot` or `execute_davis_analyzer`, returns analysis.

### T2.5 — Create notebook
```
You: Create a Dynatrace notebook called "Test Notebook" with a summary of current problems
```
Expected: Kiro calls `create_dynatrace_notebook`, returns confirmation with notebook URL/ID.

---

## Phase 3: dtctl (resource management)

### T3.1 — dtctl health check
```
You: Run dtctl doctor to check the connection
```
Expected: Kiro runs `dtctl doctor --agent`, shows structured output confirming connection.

### T3.2 — List dashboards
```
You: List my Dynatrace dashboards
```
Expected: Kiro runs `dtctl get dashboards --agent`, returns dashboard list.

### T3.3 — Create a dashboard
```
You: Create a simple dashboard called "Test Dashboard" with one tile showing error logs from the last hour
```
Expected: Kiro generates YAML, runs `dtctl apply -f`, returns confirmation. User does NOT need to run any commands.

### T3.4 — Pull dashboard as YAML
```
You: Pull the "Test Dashboard" as YAML and save it to examples/dashboards/test.yaml
```
Expected: Kiro runs `dtctl describe dashboard "Test Dashboard" -o yaml`, writes file.

### T3.5 — Delete test resources
```
You: Delete the "Test Dashboard" and the "Test Notebook" we created
```
Expected: Kiro runs `dtctl delete dashboard "Test Dashboard" --agent`.

---

## Phase 4: AWS + Dynatrace Correlation

### T4.1 — ECS service health
```
You: List my ECS services in us-west-2 and their task counts
```
Expected: Kiro runs `aws ecs list-services` + `aws ecs describe-services`, returns results.

### T4.2 — Cross-reference
```
You: Check if Dynatrace is monitoring any of those ECS services
```
Expected: Kiro takes service names from T4.1, calls `find_entity_by_name` for each.

### T4.3 — Lambda errors (if Lambda functions exist)
```
You: Show me Lambda functions with errors in the last 4 hours in us-west-2
```
Expected: Kiro queries CloudWatch metrics, then optionally correlates with Dynatrace traces.

---

## Phase 5: ACP — Obsidian

### T5.1 — Plugin installation
1. Open Obsidian → Settings → Community Plugins → Enable
2. Install BRAT → Add beta plugin `https://github.com/RAIT-09/obsidian-agent-client`
3. Enable Agent Client

Expected: Plugin appears in settings with Custom Agents section.

### T5.2 — Kiro agent configuration
Add custom agent:
- Path: output of `which kiro-cli`
- Arguments: `acp`
- Env vars: `DT_TENANT=...` and `DT_PLATFORM_TOKEN=...`

Expected: Kiro appears in agent dropdown.

### T5.3 — Basic chat in Obsidian
Select Kiro agent, send: "What Dynatrace tools do you have access to?"

Expected: Kiro responds, mentions Dynatrace MCP tools.

### T5.4 — Query from Obsidian
```
Show me open Dynatrace problems
```
Expected: Same results as T2.1 but inside Obsidian's chat panel.

### T5.5 — Note reference with @
Open `Incident Review - 2026-03-15.md`, then in chat:
```
Look at @Incident Review - 2026-03-15 and tell me what Dynatrace data would help investigate this
```
Expected: Kiro reads the note content and suggests relevant queries.

---

## Phase 6: ACP — JetBrains (optional)

### T6.1 — Configure acp.json
Create `~/.jetbrains/acp.json` with Kiro agent config.

### T6.2 — Basic chat
Open AI Chat in JetBrains IDE, select Kiro, send a Dynatrace query.

Expected: Same MCP tools available as terminal and Obsidian.

---

## Phase 7: Setup Script & Docs

### T7.1 — Fresh clone test
Clone repo into a new directory, run `./setup.sh` with env vars set.
Expected: Script completes, reports status of all prerequisites.

### T7.2 — Steering rules
```
You: Create a dashboard for my top 5 services by error rate
```
Expected: Kiro uses MCP to find the services (query), then dtctl to create the dashboard (manage).

### T7.3 — Link check
Verify all links in README.md, blog posts, and scenario docs resolve (no 404s).

---

## Test Results Template

| Test | Status | Notes |
|------|--------|-------|
| T1.1 | ⬜ | |
| T1.2 | ⬜ | |
| T1.3 | ⬜ | |
| T1.4 | ⬜ | |
| T2.1 | ⬜ | |
| T2.2 | ⬜ | |
| T2.3 | ⬜ | |
| T2.4 | ⬜ | |
| T2.5 | ⬜ | |
| T3.1 | ⬜ | |
| T3.2 | ⬜ | |
| T3.3 | ⬜ | |
| T3.4 | ⬜ | |
| T3.5 | ⬜ | |
| T4.1 | ⬜ | |
| T4.2 | ⬜ | |
| T4.3 | ⬜ | |
| T5.1 | ⬜ | |
| T5.2 | ⬜ | |
| T5.3 | ⬜ | |
| T5.4 | ⬜ | |
| T5.5 | ⬜ | |
| T6.1 | ⬜ | |
| T6.2 | ⬜ | |
| T7.1 | ⬜ | |
| T7.2 | ⬜ | |
| T7.3 | ⬜ | |
