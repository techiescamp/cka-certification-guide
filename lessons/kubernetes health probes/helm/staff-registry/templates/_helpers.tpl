{{/*
App name
*/}}
{{- define "staff-registry.appName" -}}
{{ .Release.Name }}-app
{{- end }}

{{/*
Postgres name
*/}}
{{- define "staff-registry.postgresName" -}}
{{ .Release.Name }}-postgres
{{- end }}

{{/*
Postgres service name (used as DB hostname)
*/}}
{{- define "staff-registry.postgresServiceName" -}}
{{ .Release.Name }}-postgres-svc
{{- end }}

{{/*
Common labels
*/}}
{{- define "staff-registry.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
