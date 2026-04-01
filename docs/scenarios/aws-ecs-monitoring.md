# Scenario: AWS ECS + Dynatrace Monitoring

**Level:** Intermediate | **Time:** 20 minutes | **Prerequisites:** AWS CLI configured, Dynatrace monitoring ECS, dtctl installed

## The Situation

You run microservices on ECS Fargate. Dynatrace monitors them via OneAgent. You want to use Kiro to check service health, query performance data, and manage dashboards — all from your terminal.

## Step 1: Check ECS service status

```
You: List my ECS services in us-west-2 and their running task counts
```

Kiro runs `aws ecs list-services` and `aws ecs describe-services` to show you cluster health.

## Step 2: Cross-reference with Dynatrace entities

```
You: Show me all services Dynatrace is monitoring that contain "order" in the name
```

Kiro uses `find_entity_by_name` to discover monitored services, showing entity IDs, health state, and relationships.

## Step 3: Query request latency

```
You: What's the p95 request latency for the order-service over the last 6 hours?
```

Kiro generates DQL:
```
timeseries p95_latency = percentile(dt.service.request.response_time, 95),
  filter: contains(dt.entity.service.name, "order"),
  interval: 5m
```

## Step 4: Check for deployment correlation

```
You: Were there any ECS deployments for order-service in the last 6 hours?
```

Kiro checks `aws ecs describe-services` for recent deployments and correlates timestamps with any Dynatrace problems or latency spikes.

## Step 5: Build a monitoring dashboard

```
You: Create a Dynatrace dashboard showing request rate, error rate, and p95 latency for my top 5 ECS services
```

Using dtctl, Kiro:
1. Queries Dynatrace to identify the top 5 services by request volume
2. Generates a dashboard YAML with tiles for each metric
3. Applies it with `dtctl apply -f dashboard.yaml`

## Step 6: Export for version control

```
You: Pull that dashboard as YAML so I can commit it to git
```

```bash
dtctl describe dashboard "ECS Service Health" -o yaml > examples/dashboards/ecs-health.yaml
```

## What You Learned

- Kiro bridges AWS CLI and Dynatrace data in a single conversation
- You can build dashboards conversationally and export them as code
- Deployment correlation helps identify if a deploy caused a regression
