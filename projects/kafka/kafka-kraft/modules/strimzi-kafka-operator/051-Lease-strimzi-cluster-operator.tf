# apiVersion: coordination.k8s.io/v1
# kind: Lease
# metadata:
#   name: strimzi-cluster-operator
#   namespace: {{ .Release.Namespace }}
#   labels:
#     app: {{ template "strimzi.name" . }}
#     chart: {{ template "strimzi.chart" . }}
#     component: lease
#     release: {{ .Release.Name }}
#     heritage: {{ .Release.Service }}
# spec:
#   acquireTime: "1970-01-01T00:00:01.000000Z"
#   holderIdentity: ""
#   leaseDurationSeconds: 15
#   leaseTransitions: 0
#   renewTime: "1970-01-01T00:00:01.000000Z"