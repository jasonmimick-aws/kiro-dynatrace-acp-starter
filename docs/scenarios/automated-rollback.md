# Scenario: Automated Rollback with Dynatrace Workflows

**Level:** Advanced | **Time:** 30 minutes | **Prerequisites:** dtctl installed + authenticated, ECS services monitored by Dynatrace, AWS CLI configured

## The Situation

You want Dynatrace to automatically detect when an ECS deployment goes bad and trigger a rollback. Kiro helps you build and deploy this workflow using both MCP (to understand the data model) and dtctl (to manage the workflow resource).

## Step 1: Explore the data model (MCP)

```
You: What entities does Dynatrace monitor for my checkout-service?
     Show me the deployment events from the last 24 hours.
```

Kiro uses `find_entity_by_name` and `execute_dql` to discover entity types, relationships, and what deployment event data is available. This informs the workflow design.

## Step 2: Prototype the detection query (MCP)

```
You: Write a DQL query that detects when checkout-service error rate
     exceeds 10% compared to the previous hour's baseline
```

Kiro uses `generate_dql_from_natural_language` to draft the query, then `execute_dql` to test it against real data. Iterate until the detection logic is right.

## Step 3: Build the workflow (dtctl)

```
You: Create a Dynatrace workflow that:
     1. Triggers on deployment events for checkout-service
     2. Waits 15 minutes, then evaluates error rate vs baseline using that DQL
     3. If error rate > 10% above baseline, calls AWS ECS to force a new deployment
     4. Sends a Slack notification with the decision and evidence
```

Kiro generates a workflow YAML definition. This is where dtctl is essential — the MCP server can create simple notification workflows, but complex multi-step workflows with conditional logic need dtctl's full `apply` support.

## Step 4: Deploy and verify (dtctl)

```bash
dtctl apply -f examples/workflows/auto-rollback.yaml --agent
```

```
You: Show me the workflow I just deployed and verify it looks correct
```

```bash
dtctl describe workflow "ECS Auto-Rollback" -o yaml --agent
```

## Step 5: Test with a dry run (MCP + dtctl)

```
You: Execute the workflow manually to test it
```

```bash
dtctl exec workflow "ECS Auto-Rollback" --agent
```

Then use MCP to check the result:
```
You: Show me the workflow execution history — did it succeed?
```

## Step 6: Iterate (dtctl)

```
You: Add a step that checks if this is the second consecutive failed deployment,
     and if so, page the on-call team instead of just rolling back
```

Kiro modifies the YAML, re-applies with `dtctl apply -f`, and you can pull the updated version for git:

```bash
dtctl describe workflow "ECS Auto-Rollback" -o yaml > examples/workflows/auto-rollback.yaml
```

## What You Learned

- MCP is the investigation layer: explore data models, prototype queries, check execution results
- dtctl is the management layer: create, deploy, edit, and version-control workflows
- Complex workflows (conditional logic, multi-step, external API calls) require dtctl
- The MCP server's `create_workflow_for_notification` is great for simple alerts, but dtctl handles the full workflow lifecycle
