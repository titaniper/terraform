# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/043-Crd-kafkatopic.yaml

resource "kubernetes_manifest" "kafkatopics-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkatopics.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: kafkatopics.kafka.strimzi.io-crd
spec:
  group: kafka.strimzi.io
  names:
    kind: KafkaTopic
    listKind: KafkaTopicList
    singular: kafkatopic
    plural: kafkatopics
    shortNames:
      - kt
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
        - name: Cluster
          description: The name of the Kafka cluster this topic belongs to
          jsonPath: .metadata.labels.strimzi\.io/cluster
          type: string
        - name: Partitions
          description: The desired number of partitions in the topic
          jsonPath: .spec.partitions
          type: integer
        - name: Replication factor
          description: The desired number of replicas of each partition
          jsonPath: .spec.replicas
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
                partitions:
                  type: integer
                  minimum: 1
                  description: "The number of partitions the topic should have. This cannot be decreased after topic creation. It can be increased after topic creation, but it is important to understand the consequences that has, especially for topics with semantic partitioning. When absent this will default to the broker configuration for `num.partitions`."
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 32767
                  description: The number of replicas the topic should have. When absent this will default to the broker configuration for `default.replication.factor`.
                config:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: The topic configuration.
                topicName:
                  type: string
                  description: The name of the topic. When absent this will default to the metadata.name of the topic. It is recommended to not set this unless the topic name is not a valid Kubernetes resource name.
              description: The specification of the topic.
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
                topicName:
                  type: string
                  description: Topic name.
              description: The status of the topic.
    - name: v1beta1
      served: true
      storage: false
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Cluster
          description: The name of the Kafka cluster this topic belongs to
          jsonPath: .metadata.labels.strimzi\.io/cluster
          type: string
        - name: Partitions
          description: The desired number of partitions in the topic
          jsonPath: .spec.partitions
          type: integer
        - name: Replication factor
          description: The desired number of replicas of each partition
          jsonPath: .spec.replicas
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
                partitions:
                  type: integer
                  minimum: 1
                  description: "The number of partitions the topic should have. This cannot be decreased after topic creation. It can be increased after topic creation, but it is important to understand the consequences that has, especially for topics with semantic partitioning. When absent this will default to the broker configuration for `num.partitions`."
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 32767
                  description: The number of replicas the topic should have. When absent this will default to the broker configuration for `default.replication.factor`.
                config:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: The topic configuration.
                topicName:
                  type: string
                  description: The name of the topic. When absent this will default to the metadata.name of the topic. It is recommended to not set this unless the topic name is not a valid Kubernetes resource name.
              description: The specification of the topic.
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
                topicName:
                  type: string
                  description: Topic name.
              description: The status of the topic.
    - name: v1alpha1
      served: true
      storage: false
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Cluster
          description: The name of the Kafka cluster this topic belongs to
          jsonPath: .metadata.labels.strimzi\.io/cluster
          type: string
        - name: Partitions
          description: The desired number of partitions in the topic
          jsonPath: .spec.partitions
          type: integer
        - name: Replication factor
          description: The desired number of replicas of each partition
          jsonPath: .spec.replicas
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
                partitions:
                  type: integer
                  minimum: 1
                  description: "The number of partitions the topic should have. This cannot be decreased after topic creation. It can be increased after topic creation, but it is important to understand the consequences that has, especially for topics with semantic partitioning. When absent this will default to the broker configuration for `num.partitions`."
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 32767
                  description: The number of replicas the topic should have. When absent this will default to the broker configuration for `default.replication.factor`.
                config:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: The topic configuration.
                topicName:
                  type: string
                  description: The name of the topic. When absent this will default to the metadata.name of the topic. It is recommended to not set this unless the topic name is not a valid Kubernetes resource name.
              description: The specification of the topic.
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
                topicName:
                  type: string
                  description: Topic name.
              description: The status of the topic.
  YAML
)
}
