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
{{- printf "laa-court-data-ui" }}
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


{{/*
Generate the server-snippet for IP allow list and deny all other traffic.
*/}}
{{- define "laa-court-data-ui.serverSnippet" -}}
{{- $allowList := list "51.149.249.0/27" "51.149.249.32/27" "51.149.250.0/24" "51.149.249.0/29" "194.33.249.0/29" "51.149.249.32/29" "194.33.248.0/29" "20.49.214.199/32" "20.49.214.228/32" "35.176.93.186/32" "18.130.148.126/32" "35.176.148.126/32" "18.169.147.172/32" "128.77.75.64/26" "51.149.251.0/24" "51.149.249.64/29" "194.33.192.0/18" -}}
{{- range $ip := $allowList }}
allow {{ $ip }};
{{- end }}
deny all;
{{- end }}
