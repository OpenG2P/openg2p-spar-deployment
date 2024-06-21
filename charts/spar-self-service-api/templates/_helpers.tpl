{{/*
Expand the name of the chart.
*/}}
{{- define "selfservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "selfservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "selfservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "selfservice.labels" -}}
helm.sh/chart: {{ include "selfservice.chart" . }}
{{ include "selfservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selfservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "selfservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "selfservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "selfservice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "selfservice.tpl" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- tpl $value .context }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}

{{/*
Render Env values section
*/}}
{{- define "selfservice.baseEnvVars" -}}
{{- $context := .context -}}
{{- range $k, $v := .envVars }}
- name: {{ $k }}
{{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
  value: {{ $v | quote }}
{{- else if kindIs "string" $v }}
  value: {{ include "selfservice.tpl" (dict "value" $v "context" $context) | squote }}
{{- else }}
  valueFrom: {{- include "selfservice.tpl" (dict "value" $v "context" $context) | nindent 4}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "selfservice.envVars" -}}
{{- $envVars := merge (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) -}}
{{- include "selfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}

{{/*
Render Postgres Init Env values
*/}}
{{- define "selfservice.postgresInitEnvVars" -}}
{{- $envVars := merge (deepCopy .Values.postgresInit.envVars) (deepCopy .Values.postgresInit.envVarsFrom) -}}
{{- include "selfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end }}
