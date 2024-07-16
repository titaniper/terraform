# NOTE: 헬름 차트의 createAggregateRoles 기본값이 false 라 테라폼으로 만들지 않음

# {{- if and .Values.rbac.create .Values.createAggregateRoles -}}
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRole
# metadata:
#   name: strimzi-view
#   labels:
#     app: {{ template "strimzi.name" . }}
#     chart: {{ template "strimzi.chart" . }}
#     component: entity-operator-role
#     release: {{ .Release.Name }}
#     heritage: {{ .Release.Service }}
#     # Add these permissions to the "view" default role.
#     rbac.authorization.k8s.io/aggregate-to-view: "true"
# rules:
#   - apiGroups:
#       - "kafka.strimzi.io"
#     resources:
#       - kafkas
#       - kafkaconnects
#       - kafkamirrormakers
#       - kafkausers
#       - kafkatopics
#       - kafkabridges
#       - kafkaconnectors
#       - kafkamirrormaker2s
#       - kafkarebalances
#     verbs:
#       - get
#       - list
#       - watch
#   - apiGroups:
#       - "core.strimzi.io"
#     resources:
#       - strimzipodsets
#     verbs:
#       - get
#       - list
#       - watch
# {{- end -}}