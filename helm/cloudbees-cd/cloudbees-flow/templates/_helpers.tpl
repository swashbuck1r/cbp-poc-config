{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudbees-flow.name" -}}
{{- default "cloudbees-flow" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudbees-flow.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cloudbees-flow" .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudbees-flow.chart" -}}
{{- printf "%s-%s" "cloudbees-flow" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Build DOIS nodes list
*/}}
{{- define "dois.nodes" -}}
{{- $count := .Values.dois.replicas | int -}}
{{- range $i, $e := until $count}}flow-devopsinsight-{{$i}}.flow-devopsinsight,
{{- end -}}
{{- end -}}

{{/*
Define Random Flow Credentials
*/}}
{{- define "server.cbfServerAdminPassword" -}}
{{- if .Values.flowCredentials.adminPassword }}
    {{- .Values.flowCredentials.adminPassword | b64enc | quote  -}}
{{- else -}}
    {{- $secretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "credentials" }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
    {{- if $secret }}
      {{- if (index $secret.data "CBF_SERVER_ADMIN_PASSWORD") }}
        {{- $password = index $secret.data "CBF_SERVER_ADMIN_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}

{{/*
Define Random DOIS Credentials
*/}}
{{- define "dois.cbfReportUserPassword" -}}
{{- if .Values.dois.credentials.reportUserPassword }}
    {{- .Values.dois.credentials.reportUserPassword | b64enc | quote  -}}
{{- else -}}
    {{- $doisSecretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "dois" }}
    {{- $doisSecret := (lookup "v1" "Secret" .Release.Namespace $doisSecretName) }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- if $doisSecret }}
      {{- if (index $doisSecret.data "CBF_DOIS_PASSWORD") }}
        {{- $password = index $doisSecret.data "CBF_DOIS_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}

{{- define "dois.cbfAdminPassword" -}}
{{- if .Values.dois.credentials.adminPassword }}
    {{- .Values.dois.credentials.adminPassword | b64enc | quote  -}}
{{- else -}}
    {{- $doisAdminSecretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "dois" }}
    {{- $doisAdminSecret := (lookup "v1" "Secret" .Release.Namespace $doisAdminSecretName) }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- if $doisAdminSecret }}
      {{- if (index $doisAdminSecret.data "CBF_DOIS_ADMIN_PASSWORD") }}
        {{- $password = index $doisAdminSecret.data "CBF_DOIS_ADMIN_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}

{{- end -}}
{{- end -}}

{{/*
Define Random Database Credentials
*/}}
{{- define "database.dbPassword" -}}
{{- if .Values.database.dbPassword }}
    {{- .Values.database.dbPassword | b64enc -}}
{{- else -}}
    {{- $secretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "db" }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
    {{- $password := (randAlpha 20) | b64enc }}
    {{- if $secret }}
      {{- if (index $secret.data "DB_PASSWORD") }}
        {{- $password = index $secret.data "DB_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}


{{- define "database.dbUser" -}}
  {{- if .Values.database.dbUser }}
      {{- .Values.database.dbUser | b64enc -}}
  {{- else -}}
    {{ fail "\n\nERROR:  database.dbUser is empty !!! database dbUser details missing" }}
  {{- end -}}
  {{- if .Values.mariadb.enabled -}}
    {{- if not (eq .Values.database.dbUser .Values.mariadb.db.user)  }}
      {{ fail "\n\nERROR: With mariadb.enabled = true , Set value for mariadb.db.user same as database.dbUser " }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "database.dbName" -}}
{{- if .Values.database.dbName }}
    {{- .Values.database.dbName -}}
{{- else -}}
  {{ fail "\n\nERROR:  database.dbName is empty !!! database dbName details missing" }}
{{- end -}}
{{- end -}}


{{/*
define "serviceAccount.enabled""
*/}}
{{- define "serviceAccount.enabled" -}}
{{- if or .Values.images.imagePullSecrets .Values.rbac.create -}}
true
{{- end -}}
{{- end -}}

{{- define "os.label" -}}
{{- if (semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion) }}kubernetes.io/os{{- else -}}beta.kubernetes.io/os{{- end -}}
{{- end -}}


{{/*
Define Random Mariadb Credentials
*/}}
{{- define "mariadb.rootPassword" -}}
{{ if .Values.mariadb.enabled }}
{{- $secretName := "mariadb-initdb-secret" }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- $password := (randAlpha 20) | b64enc }}
{{- if $secret }}
  {{- if (index $secret.data "mariadb-root-password") }}
    {{- $password = index $secret.data "mariadb-root-password" }}
  {{- end -}}
{{- end -}}
{{- $password }}
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow.is-openshift" -}}
{{- if or (.Values.ingress.route ) (.Capabilities.APIVersions.Has "route.openshift.io/v1") -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow.serviceAccountName" -}}
{{- if (include "serviceAccount.enabled" .) -}}
{{- .Values.rbac.serviceAccountName | default "cbflow"  -}}
{{- else -}}
{{- .Values.rbac.serviceAccountName | default "default" -}}
{{- end -}}
{{- end -}}
