## Monitoring

- [Prometheus](#prometheus)
- [Grafana](#grafana)
- [Alerting](#alerting)

### Prometheus

The prometheus_exporter gem is used to gather application metrics.

Currently the exporter runs in a separate container (laa-court-data-ui-metrics) on the default port 9394 within the same pod as the application container (laa-court-data-ui-app).

Metrics are scraped by [Cloud Platform's Prometheus instance](https://prometheus.cloud-platform.service.justice.gov.uk/graph), and can be queried by executing a suitable promql query, e.g.

```
ruby_http_duration_seconds_sum{namespace="laa-court-data-ui-staging"}
```

### Grafana

There are currently 2 separate Grafana dashboards that display metrics.

One displays the status of the [Kubernetes pods](https://grafana.cloud-platform.service.justice.gov.uk/d/CEeoatTMk/laa-court-data-ui-kubernetes-pods?orgId=1&var-namespace=laa-court-data-ui-production) and is defined in .k8s/staging/kubernetes_pods_dashboard.yaml. Note the metrics displayed in this dashboard are collected by Cloud Platform independently of the Prometheus Exporter gem.

The second displays numbers of different types of [http status request codes](https://grafana.cloud-platform.service.justice.gov.uk/d/VxuKVkoMz/laa-court-data-ui-http-status-codes?var-datasource=Prometheus&var-namespace=laa-court-data-ui-production&var-status=200) and is defined in .k8s/staging/grafana_dashboard.yaml. This does display one of the metrics scraped by Prometheus Exporter.

Currently these dashboards have been applied manually; e.g. with

```
# apply dashboard
kubectl apply -n laa-court-data-ui-staging -f .k8s/staging/http_status_codes_grafana_dashboard.yaml
```

### Alerting

PrometheusRules for AlertManager alert conditions are defined in prometheus-custom-rules.yaml for each namespace. These are integrated with Slack using a slack webhook contained in the lcdui-secrets#SLACK_ALERTS_WEBHOOK secret.

Currently these rules have been applied manually: e.g. with

```
# apply rules
kubectl apply -f .k8s/dev/prometheus-custom-rules.yaml -n laa-court-data-ui-dev
```
