## Monitoring

- [Monitoring](#monitoring)
  - [Prometheus](#prometheus)
  - [Grafana](#grafana)
  - [Alerting](#alerting)

### Prometheus

The prometheus_exporter gem is used to gather application metrics.

Currently the exporter runs in a separate container (laa-court-data-ui-metrics) on the default port 9394 within the same pod as the application container (laa-court-data-ui-app).

Metrics are scraped by [Cloud Platform's Prometheus instance](https://prometheus.cloud-platform.service.justice.gov.uk/graph), and can be queried by executing a suitable promql query, e.g.

```
ruby_http_duration_seconds_sum{namespace="laa-court-data-ui-test"}
```

### Grafana

There are currently 2 separate Grafana dashboards that display metrics.

One displays the status of the [Kubernetes pods](https://grafana.cloud-platform.service.justice.gov.uk/d/CEeoatTMk/laa-court-data-ui-kubernetes-pods?orgId=1&var-namespace=laa-court-data-ui-production) and is defined in [kubernetes_pods_dashboard.yaml](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live-1.cloud-platform.service.justice.gov.uk/laa-court-data-ui-production/kubernetes_pods_dashboard.yaml). Note the metrics displayed in this dashboard are collected by Cloud Platform independently of the Prometheus Exporter gem.

The second displays numbers of different types of [http status request codes](https://grafana.cloud-platform.service.justice.gov.uk/d/VxuKVkoMz/laa-court-data-ui-http-status-codes?var-datasource=Prometheus&var-namespace=laa-court-data-ui-production&var-status=200) and is defined in [http_status_codes_grafana_dashboard.yaml](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live-1.cloud-platform.service.justice.gov.uk/laa-court-data-ui-production/http_status_codes_grafana_dashboard.yaml). This does display one of the metrics scraped by Prometheus Exporter.

Changes to these dashboards are applied automatically by Cloud Platform Concourse.

### Alerting

PrometheusRules for AlertManager alert conditions are defined in [prometheus.yaml](https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live-1.cloud-platform.service.justice.gov.uk/laa-court-data-ui-production/prometheus.yaml) for each namespace. These are integrated with Slack using a slack webhook contained in the lcdui-secrets#SLACK_ALERTS_WEBHOOK secret.

Changes to these alerts are applied automatically by Cloud Platform Concourse.
