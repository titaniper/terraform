# NOTE: 헬름 차트의 createAggregateRoles 기본값이 false 라 테라폼으로 만들지 않음

# {{- if and .Values.rbac.create .Values.createAggregateRoles -}}
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRole
# metadata:
#   name: strimzi-admin
#   labels:
#     app: {{ template "strimzi.name" . }}
#     chart: {{ template "strimzi.chart" . }}
#     component: entity-operator-role
#     release: {{ .Release.Name }}
#     heritage: {{ .Release.Service }}
#     # Add these permissions to the "admin" and "edit" default roles.
#     rbac.authorization.k8s.io/aggregate-to-admin: "true"
#     rbac.authorization.k8s.io/aggregate-to-edit: "true"
# rules:
#   - apiGroups:
#       - "kafka.strimzi.io"
#     resources:
#       - kafkas
#       - kafkaconnects
#       - kafkaconnects/scale
#       - kafkamirrormakers
#       - kafkamirrormakers/scale
#       - kafkausers
#       - kafkatopics
#       - kafkabridges
#       - kafkabridges/scale
#       - kafkaconnectors
#       - kafkaconnectors/scale
#       - kafkamirrormaker2s
#       - kafkamirrormaker2s/scale
#       - kafkarebalances
#     verbs:
#       - get
#       - list
#       - watch
#       - create
#       - delete
#       - patch
#       - update
#   - apiGroups:
#       - "core.strimzi.io"
#     resources:
#       - strimzipodsets
#     verbs:
#       - get
#       - list
#       - watch
#       - create
#       - delete
#       - patch
#       - update
# {{- end -}}