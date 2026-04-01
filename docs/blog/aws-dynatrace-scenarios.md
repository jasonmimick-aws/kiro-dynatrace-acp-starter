# 5 AWS + Dynatrace Scenarios You Can Run from Kiro CLI

**TL;DR:** If you run workloads on AWS and monitor them with Dynatrace, Kiro CLI lets you operate both platforms from a single terminal session. Here are 5 real scenarios — from basic log queries to automated rollback workflows — that show what's possible.

---

## Why this matters

AWS gives you infrastructure. Dynatrace gives you observability. But when something breaks at 2 AM, you're bouncing between the AWS console, Dynatrace UI, CloudWatch, and Slack — copying resource IDs and timestamps between tabs.

Kiro CLI sits in the middle. It can call AWS APIs directly, query Dynatrace via MCP, and run dtctl commands — all in one conversation. You describe what you want in English, and Kiro figures out which tools to use.

**Prerequisites for all scenarios:**
- Kiro CLI with the Dynatrace MCP server configured ([setup guide](../../README.md))
- AWS CLI configured with appropriate permissions
- Dynatrace monitoring your AWS workloads

---

## Scenario 1: "Is my ECS service healthy?"

**The ask:** You want a quick health check that combines AWS task status with Dynatrace performance data.

```
You: Check the health of my order-service on ECS in us-west-2.
     Include Dynatrace error rate and latency for the last hour.
```

**What Kiro does:**
1. Runs `aws ecs describe-services` to get task counts, deployment status, and load balancer health
2. Calls `find_entity_by_name` to locate the service in Dynatrace
3. Executes DQL to pull error rate and p95 latency

**What you get:** A unified view — "3/3 tasks running, last deployed 6h ago, 0.3% error rate, 145ms p95 latency. All healthy."

**Why it's useful:** One question replaces three browser tabs.

---

## Scenario 2: "Why is my Lambda failing?"

**The ask:** CloudWatch shows Lambda errors spiking. You need the distributed trace to understand why.

```
You: My process-payment Lambda in us-west-2 has errors spiking.
     Show me CloudWatch error count, then find the failing traces in Dynatrace.
```

**What Kiro does:**
1. Queries CloudWatch `Errors` metric for the function
2. Uses Dynatrace MCP to find error traces with `execute_dql`:
   ```
   fetch spans
   | filter contains(service.name, "process-payment") AND otel.status_code == "ERROR"
   | sort timestamp desc
   | limit 5
   ```
3. For the top trace, fetches the full span chain to show where the failure originates

**What you get:** "Lambda errored 47 times in the last hour. Traces show a timeout calling the inventory-service at the `POST /api/reserve` endpoint. The inventory-service database query is taking 12s (normally 200ms)."

**Why it's useful:** CloudWatch tells you *what* failed. Dynatrace tells you *why*.

---

## Scenario 3: "Build me a dashboard for my ECS cluster"

**The ask:** You want a Dynatrace dashboard that shows key metrics for all services in your ECS cluster.

```
You: Create a Dynatrace dashboard called "ECS Cluster Health" with:
     - Request rate by service (bar chart)
     - Error rate by service (line chart)
     - p95 response time by service (line chart)
     - Active ECS task count from AWS (single value per service)
```

**What Kiro does:**
1. Queries Dynatrace to discover your monitored ECS services
2. Generates a dashboard YAML with DQL-powered tiles for each metric
3. Deploys it with `dtctl apply -f`
4. Returns the dashboard URL

**What you get:** A live dashboard in Dynatrace, plus the YAML definition saved locally for version control.

```
You: Save that dashboard YAML to examples/dashboards/ecs-cluster-health.yaml
```

**Why it's useful:** Dashboard creation that normally takes 30 minutes of clicking takes 2 minutes of conversation.

---

## Scenario 4: "Correlate a deployment with a latency spike"

**The ask:** Latency spiked 2 hours ago. Was it caused by a deployment?

```
You: Show me all ECS deployments for checkout-service in the last 6 hours,
     and overlay that with the Dynatrace latency timeseries.
```

**What Kiro does:**
1. Runs `aws ecs describe-services` to get deployment history with timestamps
2. Queries Dynatrace for the latency timeseries:
   ```
   timeseries avg_latency = avg(dt.service.request.response_time),
     filter: contains(dt.entity.service.name, "checkout"),
     interval: 5m
   ```
3. Correlates deployment timestamps with latency changes

**What you get:** "Deployment at 14:15 UTC (image tag v2.3.1 → v2.4.0). Latency jumped from 180ms to 1,200ms at 14:17 UTC. The previous deployment at 08:00 UTC had no impact."

```
You: Roll back checkout-service to the previous task definition
```

Kiro runs `aws ecs update-service --task-definition checkout-service:42 --force-new-deployment`.

**Why it's useful:** Deployment correlation that normally requires mental timestamp matching becomes automatic.

---

## Scenario 5: "Build a self-healing workflow"

**The ask:** You want Dynatrace to automatically detect bad deployments and trigger an ECS rollback.

```
You: Create a Dynatrace workflow that:
     1. Triggers when error rate for any ECS service exceeds 10%
     2. Checks if a deployment happened in the last 30 minutes
     3. If yes, rolls back the ECS service to the previous task definition
     4. Sends a Slack message to #incidents with the details
```

**What Kiro does:**
1. Generates a Dynatrace workflow YAML with:
   - A metric threshold trigger
   - A DQL step to check for recent deployments
   - A conditional branch
   - An HTTP action calling the ECS API to update the service
   - A Slack notification step
2. Deploys it with `dtctl apply -f`
3. Saves the YAML for version control

**What you get:** A closed-loop system — Dynatrace detects the problem, correlates it with a deployment, rolls back via AWS API, and notifies your team. No human in the loop.

**Why it's useful:** This is the end game — observability-driven automation that runs itself.

---

## Getting started

All five scenarios work today with the [Kiro + Dynatrace quickstart](../../README.md):

```bash
git clone https://github.com/jasonmimick-aws/kiro-dynatrace-acp-starter.git
cd kiro-dynatrace-acp-starter
./setup.sh
export DT_ENVIRONMENT="https://YOUR-ENV-ID.apps.dynatrace.com"
kiro-cli chat
```

Each scenario has a detailed step-by-step guide in the `docs/scenarios/` directory.

---

*Kiro CLI is available at [kiro.dev](https://kiro.dev). The Dynatrace MCP server and dtctl are open-source at [github.com/dynatrace-oss](https://github.com/dynatrace-oss).*
