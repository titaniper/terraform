# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/047-Crd-kafkaconnector.yaml

resource "kubernetes_manifest" "kafkaconnectors-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkaconnectors.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: kafkaconnectors.kafka.strimzi.io-crd
spec:
  group: kafka.strimzi.io
  names:
    kind: KafkaConnector
    listKind: KafkaConnectorList
    singular: kafkaconnector
    plural: kafkaconnectors
    shortNames:
      - kctr
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
        scale:
          specReplicasPath: .spec.tasksMax
          statusReplicasPath: .status.tasksMax
      additionalPrinterColumns:
        - name: Cluster
          description: The name of the Kafka Connect cluster this connector belongs to
          jsonPath: .metadata.labels.strimzi\.io/cluster
          type: string
        - name: Connector class
          description: The class used by this connector
          jsonPath: .spec.class
          type: string
        - name: Max Tasks
          description: Maximum number of tasks
          jsonPath: .spec.tasksMax
          type: integer
        - name: Ready
          description: The state of the custom resource
          jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
          type: string
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                class:
                  type: string
                  description: The Class for the Kafka Connector.
                tasksMax:
                  type: integer
                  minimum: 1
                  description: The maximum number of tasks for the Kafka Connector.
                autoRestart:
                  type: object
                  properties:
                    enabled:
                      type: boolean
                      description: Whether automatic restart for failed connectors and tasks should be enabled or disabled.
                    maxRestarts:
                      type: integer
                      description: "The maximum number of connector restarts that the operator will try. If the connector remains in a failed state after reaching this limit, it must be restarted manually by the user. Defaults to an unlimited number of restarts."
                  description: Automatic restart of connector and tasks configuration.
                config:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: "The Kafka Connector configuration. The following properties cannot be set: connector.class, tasks.max."
                pause:
                  type: boolean
                  description: Whether the connector should be paused. Defaults to false.
              description: The specification of the Kafka Connector.
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
                autoRestart:
                  type: object
                  properties:
                    count:
                      type: integer
                      description: The number of times the connector or task is restarted.
                    connectorName:
                      type: string
                      description: The name of the connector being restarted.
                    lastRestartTimestamp:
                      type: string
                      description: The last time the automatic restart was attempted. The required format is 'yyyy-MM-ddTHH:mm:ssZ' in the UTC time zone.
                  description: The auto restart status.
                connectorStatus:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: "The connector status, as reported by the Kafka Connect REST API."
                tasksMax:
                  type: integer
                  description: The maximum number of tasks for the Kafka Connector.
                topics:
                  type: array
                  items:
                    type: string
                  description: The list of topics used by the Kafka Connector.
              description: The status of the Kafka Connector.
  YAML
)
}
