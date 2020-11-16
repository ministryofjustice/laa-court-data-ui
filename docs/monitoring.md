## Monitoring

- [Prometheus](#prometheus)

### Prometheus

The prometheus_exporter gem is used to gather application metrics.

Currently the exporter runs in a separate container (laa-court-data-ui-metrics) on the default port 9394 within the same pod as the application container (laa-court-data-ui-app).

Metrics are scraped by [Cloud Platform's Prometheus instance](https://prometheus.cloud-platform.service.justice.gov.uk/graph), and can be queried by executing a suitable promql query, e.g.

```
ruby_http_duration_seconds_sum{namespace="laa-court-data-ui-staging"}
```