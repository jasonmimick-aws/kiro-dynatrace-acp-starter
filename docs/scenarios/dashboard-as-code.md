# Scenario: Dashboard-as-Code with dtctl + Kiro

**Level:** Intermediate | **Time:** 15 minutes | **Tools:** dtctl

## The Situation

Your team wants dashboards version-controlled alongside application code. Kiro + dtctl make this conversational.

## Step 1: Pull an existing dashboard

```
You: List my Dynatrace dashboards and pull the "Production Overview" one as YAML
```

Kiro runs `dtctl get dashboards` to list them, then `dtctl describe dashboard "Production Overview" -o yaml` to fetch the definition. You'll see the YAML output in Kiro's response.

## Step 2: Modify it conversationally

```
You: Add a tile showing the error rate for the checkout-service,
     and change the time range to last 24 hours
```

Kiro edits the YAML in-place, adding a new tile with the appropriate DQL query and updating the default timeframe.

## Step 3: Deploy the updated dashboard

```
You: Apply this updated dashboard to my Dynatrace environment
```

Kiro runs `dtctl apply -f` and returns confirmation with the dashboard URL.

> **What you see:** Kiro shows the dtctl output confirming the dashboard was updated, plus a link to view it in Dynatrace.

## Step 4: Create a brand new dashboard from scratch

```
You: Create a dashboard called "Lambda Health" with tiles for:
- Invocation count by function (bar chart)
- Error rate by function (line chart)
- Cold start duration p95 (single value)
- Concurrent executions (line chart)
```

Kiro generates the full dashboard YAML with DQL queries for each tile and deploys it automatically.

## Step 5: Save to git

```
You: Save this dashboard YAML to examples/dashboards/lambda-health.yaml
```

Kiro writes the file. Now the dashboard definition lives in your repo — reviewable in PRs, deployable in CI/CD.

## What You Learned

- Kiro handles the full dtctl lifecycle: list → pull → edit → deploy
- You describe what you want in English; Kiro generates the YAML and runs dtctl
- Dashboard definitions are just YAML files you can commit, review, and redeploy
