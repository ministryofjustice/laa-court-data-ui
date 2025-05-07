{{/*
Expand the name of the chart.
*/}}
{{- define "laa-court-data-ui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "laa-court-data-ui.fullName" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
laa-court-data-ui
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laa-court-data-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laa-court-data-ui.labels" -}}
helm.sh/chart: {{ include "laa-court-data-ui.chart" . }}
{{ include "laa-court-data-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laa-court-data-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laa-court-data-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Default Security Context
*/}}
{{- define "laa-court-data-ui.defaultSecurityContext" -}}
runAsNonRoot: true
allowPrivilegeEscalation: false
seccompProfile:
  type: RuntimeDefault
capabilities:
  drop: [ "ALL" ]
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laa-court-data-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laa-court-data-ui.fullName" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Function to return the internal host name of the current service
*/}}
{{- define "helm_deploy.internalHostName" -}}
  {{- printf "%s.%s.svc.cluster.local" .Values.nameOverride .Release.Namespace -}}
{{- end -}}
