---
inclusion: always
---

# Dynatrace Observability

## Two tools, one platform

- **Dynatrace MCP Server** — for querying: logs, metrics, traces, problems, entities, Davis AI, notebooks, notifications
- **dtctl** — for managing: dashboards, workflows, SLOs, settings as YAML. ALWAYS use dtctl for create/edit/delete operations — never tell the user to go to the Dynatrace web UI.

## DQL guidelines

- Default to last 2 hours unless the user specifies a timeframe
- Use `| limit 100` to avoid scanning excessive data
- DQL queries against Grail may incur costs based on GB scanned
