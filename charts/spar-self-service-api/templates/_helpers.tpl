{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "sparSelfservice.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.postgresInit.image .Values.postgresCheckerInit.image .Values.keysInit.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sparSelfservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Render Env values base
*/}}
{{- define "sparSelfservice.baseEnvVars" -}}
{{- $context := .context -}}
{{- range $k, $v := .envVars }}
{{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
- name: {{ $k }}
  value: {{ $v | quote }}
{{- else if kindIs "string" $v }}
- name: {{ $k }}
  value: {{ include "common.tplvalues.render" ( dict "value" $v "context" $context ) | squote }}
{{- else }}
{{- $vEnabled := "true" }}
{{- if hasKey $v "enabled" }}
{{- $vEnabled = kindIs "bool" $v.enabled | ternary ($v.enabled | squote) (include "common.tplvalues.render" (dict "value" $v.enabled "context" $context)) }}
{{- $v = omit $v "enabled" }}
{{- end }}
{{- if eq $vEnabled "true" }}
- name: {{ $k }}
  valueFrom: {{- include "common.tplvalues.render" ( dict "value" $v "context" $context ) | nindent 4}}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render Selfservice API Env values
*/}}
{{- define "sparSelfservice.envVars" -}}
{{- $envVars := merge (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) -}}
{{- include "sparSelfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end -}}

{{/*
Render Postgres Init Env values
*/}}
{{- define "sparSelfservice.postgresInit.envVars" -}}
{{- $envVars := merge (deepCopy .Values.postgresInit.envVars) (deepCopy .Values.postgresInit.envVarsFrom) (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) -}}
{{- include "sparSelfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end }}

{{/*
Render Keys Init Env values
*/}}
{{- define "sparSelfservice.keysInit.envVars" -}}
{{- $envVars := merge (deepCopy .Values.keysInit.envVars) (deepCopy .Values.keysInit.envVarsFrom) (deepCopy .Values.envVars) (deepCopy .Values.envVarsFrom) -}}
{{- include "sparSelfservice.baseEnvVars" (dict "envVars" $envVars "context" $) }}
{{- end }}

{{/*
Render Yaml List to Json string
*/}}
{{- define "sparSelfservice.yamlListToJsonString" -}}
{{- $context := .context -}}
{{- $list := .value -}}
[{{- range $index, $user := $list }}
{{- if eq (include "common.tplvalues.render" (dict "value" .enabled "context" $context)) "true" }}
{{- eq $index 0 | ternary "" "," }}
{{- include "common.tplvalues.render" (dict "value" (omit . "enabled") "context" $context) | fromYaml | toJson }}
{{- end }}
{{- end -}}]
{{- end }}
