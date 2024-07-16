# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/049-Crd-kafkarebalance.yaml

resource "kubernetes_manifest" "kafkarebalances-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkarebalances.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: kafkarebalances.kafka.strimzi.io-crd
spec:
  group: kafka.strimzi.io
  names:
    kind: KafkaRebalance
    listKind: KafkaRebalanceList
    singular: kafkarebalance
    plural: kafkarebalances
    shortNames:
      - kr
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
          description: The name of the Kafka cluster this resource rebalances
          jsonPath: .metadata.labels.strimzi\.io/cluster
          type: string
        - name: PendingProposal
          description: A proposal has been requested from Cruise Control
          jsonPath: ".status.conditions[?(@.type==\"PendingProposal\")].status"
          type: string
        - name: ProposalReady
          description: A proposal is ready and waiting for approval
          jsonPath: ".status.conditions[?(@.type==\"ProposalReady\")].status"
          type: string
        - name: Rebalancing
          description: Cruise Control is doing the rebalance
          jsonPath: ".status.conditions[?(@.type==\"Rebalancing\")].status"
          type: string
        - name: Ready
          description: The rebalance is complete
          jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
          type: string
        - name: NotReady
          description: There is an error on the custom resource
          jsonPath: ".status.conditions[?(@.type==\"NotReady\")].status"
          type: string
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                mode:
                  type: string
                  enum:
                    - full
                    - add-brokers
                    - remove-brokers
                  description: "Mode to run the rebalancing. The supported modes are `full`, `add-brokers`, `remove-brokers`.\nIf not specified, the `full` mode is used by default. \n\n* `full` mode runs the rebalancing across all the brokers in the cluster.\n* `add-brokers` mode can be used after scaling up the cluster to move some replicas to the newly added brokers.\n* `remove-brokers` mode can be used before scaling down the cluster to move replicas out of the brokers to be removed.\n"
                brokers:
                  type: array
                  items:
                    type: integer
                  description: The list of newly added brokers in case of scaling up or the ones to be removed in case of scaling down to use for rebalancing. This list can be used only with rebalancing mode `add-brokers` and `removed-brokers`. It is ignored with `full` mode.
                goals:
                  type: array
                  items:
                    type: string
                  description: "A list of goals, ordered by decreasing priority, to use for generating and executing the rebalance proposal. The supported goals are available at https://github.com/linkedin/cruise-control#goals. If an empty goals list is provided, the goals declared in the default.goals Cruise Control configuration parameter are used."
                skipHardGoalCheck:
                  type: boolean
                  description: Whether to allow the hard goals specified in the Kafka CR to be skipped in optimization proposal generation. This can be useful when some of those hard goals are preventing a balance solution being found. Default is false.
                rebalanceDisk:
                  type: boolean
                  description: "Enables intra-broker disk balancing, which balances disk space utilization between disks on the same broker. Only applies to Kafka deployments that use JBOD storage with multiple disks. When enabled, inter-broker balancing is disabled. Default is false."
                excludedTopics:
                  type: string
                  description: A regular expression where any matching topics will be excluded from the calculation of optimization proposals. This expression will be parsed by the java.util.regex.Pattern class; for more information on the supported format consult the documentation for that class.
                concurrentPartitionMovementsPerBroker:
                  type: integer
                  minimum: 0
                  description: The upper bound of ongoing partition replica movements going into/out of each broker. Default is 5.
                concurrentIntraBrokerPartitionMovements:
                  type: integer
                  minimum: 0
                  description: The upper bound of ongoing partition replica movements between disks within each broker. Default is 2.
                concurrentLeaderMovements:
                  type: integer
                  minimum: 0
                  description: The upper bound of ongoing partition leadership movements. Default is 1000.
                replicationThrottle:
                  type: integer
                  minimum: 0
                  description: "The upper bound, in bytes per second, on the bandwidth used to move replicas. There is no limit by default."
                replicaMovementStrategies:
                  type: array
                  items:
                    type: string
                  description: "A list of strategy class names used to determine the execution order for the replica movements in the generated optimization proposal. By default BaseReplicaMovementStrategy is used, which will execute the replica movements in the order that they were generated."
              description: The specification of the Kafka rebalance.
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
                sessionId:
                  type: string
                  description: The session identifier for requests to Cruise Control pertaining to this KafkaRebalance resource. This is used by the Kafka Rebalance operator to track the status of ongoing rebalancing operations.
                optimizationResult:
                  x-kubernetes-preserve-unknown-fields: true
                  type: object
                  description: A JSON object describing the optimization result.
              description: The status of the Kafka rebalance.
  YAML
)
}
