# Scenario: Incident Investigation with Kiro + Dynatrace

**Level:** Beginner | **Time:** 10 minutes | **Tools:** MCP + dtctl + AWS CLI

This scenario works from the terminal (`kiro-cli chat`), Obsidian, JetBrains, or any ACP client.

## Step 1: Check for open problems

```
You: Are there any open problems in my Dynatrace environment?
```

Kiro uses the `list_problems` MCP tool and returns active problems with severity, affected entities, and root cause.

## Step 2: Drill into root cause

```
You: Show me details on the highest severity problem, including root cause analysis
```

Kiro calls Davis AI via MCP and presents the root cause — which service failed, what changed, and what's affected downstream.

## Step 3: Pull related logs

```
You: Show me error logs from the affected service in the last 30 minutes
```

Kiro generates and executes DQL:
```
fetch logs
| filter loglevel == "ERROR" AND contains(dt.entity.service, "payment-service")
| sort timestamp desc
| limit 50
```

## Step 4: Check the AWS side

```
You: Check the ECS task status for the payment-service in us-west-2
```

Kiro runs `aws ecs describe-services` and `aws ecs list-tasks` to correlate ECS task health with what Dynatrace reports.

## Step 5: Correlate traces

```
You: Find error traces for payment-service in the last 30 minutes, show the slowest ones
```

Kiro runs DQL against spans and follows trace IDs across services.

## Step 6: Save findings as a notebook

```
You: Create a Dynatrace notebook with these findings for the postmortem
```

Kiro uses `create_dynatrace_notebook` via MCP to save the investigation as a shareable notebook in Dynatrace.

## Step 7: Build a monitoring dashboard

```
You: Create a dashboard showing error rate, latency, and throughput for payment-service
```

Kiro handles this end-to-end:
1. Generates a dashboard YAML with the right DQL queries
2. Runs `dtctl apply -f` to deploy it to Dynatrace
3. Returns the dashboard URL so you can open it in a browser

> **Under the hood:** Kiro writes a temporary YAML file and runs `dtctl apply -f /tmp/dashboard.yaml --agent`. You don't need to run dtctl yourself — Kiro does it for you.

## Step 8: Version-control the dashboard (optional, manual)

If you want to save the dashboard definition for git, you can ask:

```
You: Pull that dashboard as YAML and save it to examples/dashboards/
```

Kiro runs `dtctl describe dashboard "Payment Service Health" -o yaml` and writes the file.

## What You Learned

- MCP tools handle investigation: problems, logs, traces, Davis AI, notebooks
- dtctl handles resource management: Kiro runs it automatically when you ask to create/edit dashboards, workflows, or SLOs
- You only touch dtctl directly if you want to pull resources for version control
