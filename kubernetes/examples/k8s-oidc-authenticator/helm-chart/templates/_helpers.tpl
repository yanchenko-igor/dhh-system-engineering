{{- define "allowed_email_addresses" -}}
"{{- if .Values.role_bindings.cluster_admin -}}
{{- join "," .Values.role_bindings.cluster_admin -}}
{{- end }}
{{- if .Values.role_bindings.namespaces -}}
{{- range $key, $val := .Values.role_bindings.namespaces -}}
,{{- join "," $val -}}
{{- end -}}
{{- end -}}"
{{- end -}}
