# Scenario: Obsidian + Dynatrace (Notes Meet Observability)

**Level:** Beginner | **Time:** 15 minutes | **Tools:** MCP + dtctl

## The Situation

You're in a meeting reviewing a production incident. You're taking notes in Obsidian. Instead of switching to a browser to check Dynatrace, you ask Kiro — right there in your notes.

## Step 1: Open the vault and agent chat

Open `obsidian-vault/` in Obsidian. Click the robot icon in the left ribbon and select **Kiro**. No extra configuration needed — Kiro picks up your Dynatrace MCP config from `~/.kiro/settings/mcp.json`.

## Step 2: Investigate from your notes

Open the `Incident Review - 2026-03-15` note. In the chat, reference it with `@`:

```
Look at @Incident Review - 2026-03-15 — pull the Dynatrace problems
and error traces for checkout-service around 14:00 UTC
```

Kiro reads your note for context, then queries Dynatrace via MCP to fetch matching problems and traces.

## Step 3: Ask Davis AI for analysis

```
Based on those traces, ask Davis what the root cause is
```

Kiro calls Davis AI via MCP and returns the root cause analysis.

## Step 4: Check AWS health

```
Are the ECS tasks for checkout-service healthy in us-west-2?
Were there any deployments in the last 6 hours?
```

Kiro runs `aws ecs describe-services` to correlate infrastructure state.

## Step 5: Create an SLO for the affected service

```
Create a Dynatrace SLO for checkout-service: 99.5% availability target,
evaluated over a rolling 7-day window
```

Kiro generates the SLO definition and deploys it by running `dtctl apply -f` automatically. You'll see the dtctl output in Kiro's response confirming the SLO was created.

## Step 6: Build a dashboard from the investigation

```
Create a dashboard with the key metrics from this investigation:
checkout-service error rate, p95 latency, and deployment events
```

Kiro generates the dashboard YAML, deploys it via dtctl, and returns the Dynatrace URL where you can view it.

## Step 7: Save the dashboard definition to your vault

```
Save that dashboard YAML to my vault so I can reference it later
```

Kiro writes the YAML file into your Obsidian vault. You can also export the chat conversation as a Markdown note — a permanent record of the investigation.

## What You Learned

- Kiro works inside Obsidian via ACP — same Dynatrace capabilities as the terminal
- `@note` references give Kiro context from your existing notes
- When you ask Kiro to create resources (dashboards, SLOs), it runs dtctl for you
- You only interact with dtctl directly if you want to pull YAML for version control
