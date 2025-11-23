{{/*
Expand the name of the chart.
*/}}
{{- define "selfservice.name" -}}
{{- $values := index .Values "spar-self-service-api" -}}
{{- default "spar-self-service-api" $values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "selfservice.fullname" -}}
{{- $values := index .Values "spar-self-service-api" -}}
{{- if $values.fullnameOverride }}
{{- $values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "spar-self-service-api" $values.nameOverride }}
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
{{- printf "%s-%s" "spar-self-service-api" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
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
{{- $values := index .Values "spar-self-service-api" -}}
{{- if $values.serviceAccount.create }}
{{- default (include "selfservice.fullname" .) $values.serviceAccount.name }}
{{- else }}
{{- default "default" $values.serviceAccount.name }}
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
{{- $values := index .Values "spar-self-service-api" -}}
{{- $envVars := merge (deepCopy $values.envVars) (deepCopy $values.envVarsFrom) -}}
{{- include "selfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}

{{/*
Render Postgres Init Env values
*/}}
{{- define "selfservice.postgresInitEnvVars" -}}
{{- $values := index .Values "spar-self-service-api" -}}
{{- $envVars := merge (deepCopy $values.postgresInit.envVars) (deepCopy $values.postgresInit.envVarsFrom) -}}
{{- include "selfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end }}
