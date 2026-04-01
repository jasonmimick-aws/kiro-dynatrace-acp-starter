# Useful DQL Query Templates

## Error logs (last 2 hours)
```
fetch logs
| filter loglevel == "ERROR"
| sort timestamp desc
| limit 100
| fields timestamp, content, service.name, loglevel
```

## Error logs for a specific service
```
fetch logs
| filter loglevel == "ERROR" AND contains(service.name, "{{.service}}")
| sort timestamp desc
| limit 50
```

## Service request latency (timeseries)
```
timeseries p95_latency = percentile(dt.service.request.response_time, 95),
  filter: contains(dt.entity.service.name, "{{.service}}"),
  interval: 5m
```

## Error rate by service (top 10)
```
fetch dt.service.request
| summarize errors = sum(if(failure_rate > 0, 1, 0)), total = count()
| fieldsAdd error_rate = 100.0 * errors / total
| sort error_rate desc
| limit 10
```

## Traces with errors
```
fetch spans
| filter otel.status_code == "ERROR"
| sort timestamp desc
| limit 20
| fields trace_id, span.name, duration, service.name, exception.message
```

## Full trace by trace ID
```
fetch spans
| filter trace_id == "{{.traceId}}"
| sort timestamp asc
| fields span.name, service.name, duration, otel.status_code, parent_span_id
```

## Deployment events (last 24 hours)
```
fetch events
| filter event.type == "CUSTOM_DEPLOYMENT"
| sort timestamp desc
| limit 20
| fields timestamp, event.name, affected_entity.name, deployment.version
```

## Kubernetes pod status
```
fetch dt.entity.cloud_application
| filter entity.type == "CLOUD_APPLICATION"
| fields entity.name, running_pods, desired_pods, namespace
```
