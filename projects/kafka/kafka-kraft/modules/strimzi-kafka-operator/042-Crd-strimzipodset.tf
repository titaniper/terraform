# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/042-Crd-strimzipodset.yaml

resource "kubernetes_manifest" "strimzipodsets-core-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: strimzipodsets.core.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: stirmzipodsets.core.strimzi.io-crd
spec:
  group: core.strimzi.io
  names:
    kind: StrimziPodSet
    listKind: StrimziPodSetList
    singular: strimzipodset
    plural: strimzipodsets
    shortNames:
      - sps
    categories:
      - strimzi
  scope: Namespaced
  conversion:
    strategy: None
  versions:
    - name: v1beta2
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Pods
          description: Number of pods managed by the StrimziPodSet
          jsonPath: .status.pods
          type: integer
        - name: Ready Pods
          description: Number of ready pods managed by the StrimziPodSet
          jsonPath: .status.readyPods
          type: integer
        - name: Current Pods
          description: Number of up-to-date pods managed by the StrimziPodSet
          jsonPath: .status.currentPods
          type: integer
        - name: Age
          description: Age of the StrimziPodSet
          jsonPath: .metadata.creationTimestamp
          type: date
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                selector:
                  type: object
                  properties:
                    matchExpressions:
                      type: array
                      items:
                        type: object
                        properties:
                          key:
                            type: string
                          operator:
                            type: string
                          values:
                            type: array
                            items:
                              type: string
                    matchLabels:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                  description: "Selector is a label query which matches all the pods managed by this `StrimziPodSet`. Only `matchLabels` is supported. If `matchExpressions` is set, it will be ignored."
                pods:
                  type: array
                  items:
                    x-kubernetes-preserve-unknown-fields: true
                    type: object
                  description: The Pods managed by this StrimziPodSet.
              required:
                - selector
                - pods
              description: The specification of the StrimziPodSet.
            status:
              type: object
              properties:
                conditions:
                  type: array
                  items:
                    type: object
                    properties:
                      type:
                        type: string
                        description: "The unique identifier of a condition, used to distinguish between other conditions in the resource."
                      status:
                        type: string
                        description: "The status of the condition, either True, False or Unknown."
                      lastTransitionTime:
                        type: string
                        description: "Last time the condition of a type changed from one status to another. The required format is 'yyyy-MM-ddTHH:mm:ssZ', in the UTC time zone."
                      reason:
                        type: string
                        description: The reason for the condition's last transition (a single word in CamelCase).
                      message:
                        type: string
                        description: Human-readable message indicating details about the condition's last transition.
                  description: List of status conditions.
                observedGeneration:
                  type: integer
                  description: The generation of the CRD that was last reconciled by the operator.
                pods:
                  type: integer
                  description: Number of pods managed by this `StrimziPodSet` resource.
                readyPods:
                  type: integer
                  description: Number of pods managed by this `StrimziPodSet` resource that are ready.
                currentPods:
                  type: integer
                  description: Number of pods managed by this `StrimziPodSet` resource that have the current revision.
              description: The status of the StrimziPodSet.
  YAML
)
}
