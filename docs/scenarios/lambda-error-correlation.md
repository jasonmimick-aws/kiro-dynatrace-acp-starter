# Scenario: Lambda Error Correlation

**Level:** Advanced | **Time:** 25 minutes | **Prerequisites:** AWS CLI configured, Lambda functions monitored by Dynatrace

## The Situation

Your Lambda functions are throwing errors. CloudWatch shows invocation failures, but you need Dynatrace's distributed tracing to understand the full picture — which downstream services are affected, where the bottleneck is, and what changed.

## Step 1: Identify failing Lambda functions

```
You: Show me Lambda functions in us-west-2 with errors in the last 4 hours
```

Kiro queries CloudWatch metrics:
```bash
aws cloudwatch get-metric-statistics --namespace AWS/Lambda \
  --metric-name Errors --period 3600 --statistics Sum \
  --start-time ... --end-time ... --no-cli-pager
```

## Step 2: Get Dynatrace's view of the same functions

```
You: Show me Dynatrace entities for Lambda functions containing "process-order"
```

Kiro uses `find_entity_by_name` to find the monitored Lambda entities and their health state.

## Step 3: Trace a failing invocation end-to-end

```
You: Find distributed traces for process-order-lambda with errors in the last 4 hours, show the full call chain
```

Kiro executes DQL to find error traces and follows the trace ID across services:
```
fetch spans
| filter contains(service.name, "process-order") AND otel.status_code == "ERROR"
| sort timestamp desc
| limit 5
| fields trace_id, span.name, duration, service.name, exception.message
```

Then for a specific trace:
```
fetch spans
| filter trace_id == "abc123..."
| sort timestamp asc
| fields span.name, service.name, duration, otel.status_code
```

## Step 4: Correlate with Lambda logs

```
You: Pull the Dynatrace logs for that trace ID
```

```
fetch logs
| filter trace_id == "abc123..."
| sort timestamp asc
| fields timestamp, content, loglevel, service.name
```

## Step 5: Check if a deployment caused it

```
You: When was the last deployment of process-order-lambda and did error rates spike after it?
```

Kiro checks:
1. `aws lambda get-function --function-name process-order-lambda` for `LastModified`
2. Dynatrace deployment events via DQL
3. Error rate timeseries around the deployment timestamp

## Step 6: Build an alert workflow

```
You: Create a Dynatrace workflow that sends a Slack notification when process-order-lambda error rate exceeds 5%
```

Kiro generates a workflow YAML and deploys it with dtctl.

## What You Learned

- CloudWatch gives you the "what" (errors happened), Dynatrace gives you the "why" (full trace)
- Trace IDs are the bridge between Lambda invocations and distributed traces
- Kiro can correlate deployment timestamps with error rate changes
- You can build alerting workflows conversationally
