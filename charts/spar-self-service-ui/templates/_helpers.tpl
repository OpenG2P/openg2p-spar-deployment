{{/*
Expand the name of the chart.
*/}}
{{- define "selfserviceUi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "selfserviceUi.fullname" -}}
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
{{- define "selfserviceUi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "selfserviceUi.labels" -}}
helm.sh/chart: {{ include "selfserviceUi.chart" . }}
{{ include "selfserviceUi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selfserviceUi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "selfserviceUi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "selfserviceUi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "selfserviceUi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "selfserviceUi.tpl" -}}
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
{{- define "selfserviceUi.baseEnvVars" -}}
{{- $context := .context -}}
{{- range $k, $v := .envVars }}
- name: {{ $k }}
{{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
  value: {{ $v | quote }}
{{- else if kindIs "string" $v }}
  value: {{ include "selfserviceUi.tpl" (dict "value" $v "context" $context) | squote }}
{{- else }}
  valueFrom: {{- include "selfserviceUi.tpl" (dict "value" $v "context" $context) | nindent 4}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "selfserviceUi.envVars" -}}
{{- $envVars := merge (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) -}}
{{- include "selfserviceUi.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}
