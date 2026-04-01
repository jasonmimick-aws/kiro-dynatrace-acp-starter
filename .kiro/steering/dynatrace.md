---
inclusion: always
---

# Dynatrace Observability Rules

## Two tools, one platform

Kiro has two paths to Dynatrace. Use the right one for the job:

### Dynatrace MCP Server (query & investigate)
Use MCP tools when the user asks to:
- Query logs, metrics, traces, or spans (execute_dql, generate_dql_from_natural_language)
- List or investigate problems, vulnerabilities, exceptions (list_problems, list_vulnerabilities)
- Find entities by name (find_entity_by_name)
- Ask Davis AI questions (chat_with_davis_copilot, execute_davis_analyzer)
- Send notifications (send_slack_message, send_email, send_event)
- Create notebooks to share findings (create_dynatrace_notebook)
- Create simple notification workflows (create_workflow_for_notification)

### dtctl CLI (manage & deploy resources)
Use `dtctl` via shell when the user needs to:
- List, create, edit, or delete dashboards (`dtctl get dashboards`, `dtctl edit dashboard`)
- Manage workflows as YAML (`dtctl describe workflow -o yaml`, `dtctl apply -f`)
- Manage SLOs (`dtctl get slos`, `dtctl apply -f slo.yaml`)
- Manage settings, segments, buckets, or lookup tables
- Pull any resource as YAML for version control
- Switch Dynatrace environments (`dtctl ctx`)
- Run health checks (`dtctl doctor`)

Always use `--agent` flag with dtctl for structured JSON output.

### When to combine both
Many scenarios use both tools in sequence:
1. MCP to investigate (query logs, find problems, discover entities)
2. dtctl to act on findings (create dashboard, deploy workflow, update SLO)

Example: "Find services with >5% error rate and create a dashboard for them"
- Step 1: MCP `execute_dql` to find the services
- Step 2: dtctl to generate and apply the dashboard YAML

## DQL query guidelines

- Default to last 2 hours unless the user specifies a timeframe
- Use `| limit 100` to avoid scanning excessive data
- When querying logs, filter by `loglevel` when possible
- Remind users that DQL queries against Grail may incur costs based on GB scanned

## AWS + Dynatrace correlation

When the user asks to correlate AWS and Dynatrace data:
1. Use AWS CLI to get resource status (ECS tasks, Lambda invocations, CloudWatch metrics)
2. Use Dynatrace MCP tools to get traces/logs for the same timeframe
3. Correlate by timestamp, trace ID, or entity name
