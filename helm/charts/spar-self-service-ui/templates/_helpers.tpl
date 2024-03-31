{{/*
Expand the name of the chart.
*/}}
{{- define "sparSelfServiceUi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sparSelfServiceUi.fullname" -}}
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
{{- define "sparSelfServiceUi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sparSelfServiceUi.labels" -}}
helm.sh/chart: {{ include "sparSelfServiceUi.chart" . }}
{{ include "sparSelfServiceUi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sparSelfServiceUi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sparSelfServiceUi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sparSelfServiceUi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sparSelfServiceUi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render Env values section
*/}}
{{- define "sparSelfServiceUi.envVars" -}}
{{- range $k, $v := .Values.envVars }}
- name: {{ $k }}
  value: {{ tpl $v $ | quote }}
{{- end }}
{{- range $k, $v := .Values.envVarsFrom }}
- name: {{ $k }}
  valueFrom:
    {{- if $v.configMapKeyRef }}
    configMapKeyRef:
      name: {{ tpl $v.configMapKeyRef.name $ | quote }}
      key: {{ tpl $v.configMapKeyRef.key $ | quote }}
    {{- else if $v.secretKeyRef }}
    secretKeyRef:
      name: {{ tpl $v.secretKeyRef.name $ | quote }}
      key: {{ tpl $v.secretKeyRef.key $ | quote }}
    {{- end }}
{{- end }}
{{- end }}
