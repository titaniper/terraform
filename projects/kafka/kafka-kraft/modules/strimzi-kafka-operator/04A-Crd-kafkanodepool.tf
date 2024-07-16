# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/04A-Crd-kafkanodepool.yaml

resource "kubernetes_manifest" "kafkanodepool-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkanodepools.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
spec:
  group: kafka.strimzi.io
  names:
    kind: KafkaNodePool
    listKind: KafkaNodePoolList
    singular: kafkanodepool
    plural: kafkanodepools
    shortNames:
    - knp
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
        specReplicasPath: .spec.replicas
        statusReplicasPath: .status.replicas
        labelSelectorPath: .status.labelSelector
    additionalPrinterColumns:
    - name: Desired replicas
      description: The desired number of replicas
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
              replicas:
                type: integer
                minimum: 0
                description: The number of pods in the pool.
              storage:
                type: object
                properties:
                  class:
                    type: string
                    description: The storage class to use for dynamic volume allocation.
                  deleteClaim:
                    type: boolean
                    description: Specifies if the persistent volume claim has to be deleted when the cluster is un-deployed.
                  id:
                    type: integer
                    minimum: 0
                    description: Storage identification number. It is mandatory only for storage volumes defined in a storage of type 'jbod'.
                  overrides:
                    type: array
                    items:
                      type: object
                      properties:
                        class:
                          type: string
                          description: The storage class to use for dynamic volume allocation for this broker.
                        broker:
                          type: integer
                          description: Id of the kafka broker (broker identifier).
                    description: Overrides for individual brokers. The `overrides` field allows to specify a different configuration for different brokers.
                  selector:
                    x-kubernetes-preserve-unknown-fields: true
                    type: object
                    description: Specifies a specific persistent volume to use. It contains key:value pairs representing labels for selecting such a volume.
                  size:
                    type: string
                    description: "When type=persistent-claim, defines the size of the persistent volume claim (i.e 1Gi). Mandatory when type=persistent-claim."
                  sizeLimit:
                    type: string
                    pattern: "^([0-9.]+)([eEinumkKMGTP]*[-+]?[0-9]*)$"
                    description: "When type=ephemeral, defines the total amount of local storage required for this EmptyDir volume (for example 1Gi)."
                  type:
                    type: string
                    enum:
                    - ephemeral
                    - persistent-claim
                    - jbod
                    description: "Storage type, must be either 'ephemeral', 'persistent-claim', or 'jbod'."
                  volumes:
                    type: array
                    items:
                      type: object
                      properties:
                        class:
                          type: string
                          description: The storage class to use for dynamic volume allocation.
                        deleteClaim:
                          type: boolean
                          description: Specifies if the persistent volume claim has to be deleted when the cluster is un-deployed.
                        id:
                          type: integer
                          minimum: 0
                          description: Storage identification number. It is mandatory only for storage volumes defined in a storage of type 'jbod'.
                        overrides:
                          type: array
                          items:
                            type: object
                            properties:
                              class:
                                type: string
                                description: The storage class to use for dynamic volume allocation for this broker.
                              broker:
                                type: integer
                                description: Id of the kafka broker (broker identifier).
                          description: Overrides for individual brokers. The `overrides` field allows to specify a different configuration for different brokers.
                        selector:
                          x-kubernetes-preserve-unknown-fields: true
                          type: object
                          description: Specifies a specific persistent volume to use. It contains key:value pairs representing labels for selecting such a volume.
                        size:
                          type: string
                          description: "When type=persistent-claim, defines the size of the persistent volume claim (i.e 1Gi). Mandatory when type=persistent-claim."
                        sizeLimit:
                          type: string
                          pattern: "^([0-9.]+)([eEinumkKMGTP]*[-+]?[0-9]*)$"
                          description: "When type=ephemeral, defines the total amount of local storage required for this EmptyDir volume (for example 1Gi)."
                        type:
                          type: string
                          enum:
                          - ephemeral
                          - persistent-claim
                          description: "Storage type, must be either 'ephemeral' or 'persistent-claim'."
                      required:
                      - type
                    description: List of volumes as Storage objects representing the JBOD disks array.
                required:
                - type
                description: Storage configuration (disk). Cannot be updated.
              roles:
                type: array
                items:
                  type: string
                  enum:
                  - controller
                  - broker
                description: "The roles that the nodes in this pool will have when KRaft mode is enabled. Supported values are 'broker' and 'controller'. This field is required. When KRaft mode is disabled, the only allowed value if `broker`."
              resources:
                type: object
                properties:
                  claims:
                    type: array
                    items:
                      type: object
                      properties:
                        name:
                          type: string
                  limits:
                    x-kubernetes-preserve-unknown-fields: true
                    type: object
                  requests:
                    x-kubernetes-preserve-unknown-fields: true
                    type: object
                description: CPU and memory resources to reserve.
              jvmOptions:
                type: object
                properties:
                  "-XX":
                    x-kubernetes-preserve-unknown-fields: true
                    type: object
                    description: A map of -XX options to the JVM.
                  "-Xms":
                    type: string
                    pattern: "^[0-9]+[mMgG]?$"
                    description: -Xms option to to the JVM.
                  "-Xmx":
                    type: string
                    pattern: "^[0-9]+[mMgG]?$"
                    description: -Xmx option to to the JVM.
                  gcLoggingEnabled:
                    type: boolean
                    description: Specifies whether the Garbage Collection logging is enabled. The default is false.
                  javaSystemProperties:
                    type: array
                    items:
                      type: object
                      properties:
                        name:
                          type: string
                          description: The system property name.
                        value:
                          type: string
                          description: The system property value.
                    description: A map of additional system properties which will be passed using the `-D` option to the JVM.
                description: JVM Options for pods.
              template:
                type: object
                properties:
                  podSet:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                    description: Template for Kafka `StrimziPodSet` resource.
                  pod:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                      imagePullSecrets:
                        type: array
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                        description: "List of references to secrets in the same namespace to use for pulling any of the images used by this Pod. When the `STRIMZI_IMAGE_PULL_SECRETS` environment variable in Cluster Operator and the `imagePullSecrets` option are specified, only the `imagePullSecrets` variable is used and the `STRIMZI_IMAGE_PULL_SECRETS` variable is ignored."
                      securityContext:
                        type: object
                        properties:
                          fsGroup:
                            type: integer
                          fsGroupChangePolicy:
                            type: string
                          runAsGroup:
                            type: integer
                          runAsNonRoot:
                            type: boolean
                          runAsUser:
                            type: integer
                          seLinuxOptions:
                            type: object
                            properties:
                              level:
                                type: string
                              role:
                                type: string
                              type:
                                type: string
                              user:
                                type: string
                          seccompProfile:
                            type: object
                            properties:
                              localhostProfile:
                                type: string
                              type:
                                type: string
                          supplementalGroups:
                            type: array
                            items:
                              type: integer
                          sysctls:
                            type: array
                            items:
                              type: object
                              properties:
                                name:
                                  type: string
                                value:
                                  type: string
                          windowsOptions:
                            type: object
                            properties:
                              gmsaCredentialSpec:
                                type: string
                              gmsaCredentialSpecName:
                                type: string
                              hostProcess:
                                type: boolean
                              runAsUserName:
                                type: string
                        description: Configures pod-level security attributes and common container settings.
                      terminationGracePeriodSeconds:
                        type: integer
                        minimum: 0
                        description: "The grace period is the duration in seconds after the processes running in the pod are sent a termination signal, and the time when the processes are forcibly halted with a kill signal. Set this value to longer than the expected cleanup time for your process. Value must be a non-negative integer. A zero value indicates delete immediately. You might need to increase the grace period for very large Kafka clusters, so that the Kafka brokers have enough time to transfer their work to another broker before they are terminated. Defaults to 30 seconds."
                      affinity:
                        type: object
                        properties:
                          nodeAffinity:
                            type: object
                            properties:
                              preferredDuringSchedulingIgnoredDuringExecution:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    preference:
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
                                        matchFields:
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
                                    weight:
                                      type: integer
                              requiredDuringSchedulingIgnoredDuringExecution:
                                type: object
                                properties:
                                  nodeSelectorTerms:
                                    type: array
                                    items:
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
                                        matchFields:
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
                          podAffinity:
                            type: object
                            properties:
                              preferredDuringSchedulingIgnoredDuringExecution:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    podAffinityTerm:
                                      type: object
                                      properties:
                                        labelSelector:
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
                                        namespaceSelector:
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
                                        namespaces:
                                          type: array
                                          items:
                                            type: string
                                        topologyKey:
                                          type: string
                                    weight:
                                      type: integer
                              requiredDuringSchedulingIgnoredDuringExecution:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    labelSelector:
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
                                    namespaceSelector:
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
                                    namespaces:
                                      type: array
                                      items:
                                        type: string
                                    topologyKey:
                                      type: string
                          podAntiAffinity:
                            type: object
                            properties:
                              preferredDuringSchedulingIgnoredDuringExecution:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    podAffinityTerm:
                                      type: object
                                      properties:
                                        labelSelector:
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
                                        namespaceSelector:
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
                                        namespaces:
                                          type: array
                                          items:
                                            type: string
                                        topologyKey:
                                          type: string
                                    weight:
                                      type: integer
                              requiredDuringSchedulingIgnoredDuringExecution:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    labelSelector:
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
                                    namespaceSelector:
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
                                    namespaces:
                                      type: array
                                      items:
                                        type: string
                                    topologyKey:
                                      type: string
                        description: The pod's affinity rules.
                      tolerations:
                        type: array
                        items:
                          type: object
                          properties:
                            effect:
                              type: string
                            key:
                              type: string
                            operator:
                              type: string
                            tolerationSeconds:
                              type: integer
                            value:
                              type: string
                        description: The pod's tolerations.
                      priorityClassName:
                        type: string
                        description: "The name of the priority class used to assign priority to the pods. For more information about priority classes, see {K8sPriorityClass}."
                      schedulerName:
                        type: string
                        description: "The name of the scheduler used to dispatch this `Pod`. If not specified, the default scheduler will be used."
                      hostAliases:
                        type: array
                        items:
                          type: object
                          properties:
                            hostnames:
                              type: array
                              items:
                                type: string
                            ip:
                              type: string
                        description: The pod's HostAliases. HostAliases is an optional list of hosts and IPs that will be injected into the Pod's hosts file if specified.
                      tmpDirSizeLimit:
                        type: string
                        pattern: "^([0-9.]+)([eEinumkKMGTP]*[-+]?[0-9]*)$"
                        description: Defines the total amount (for example `1Gi`) of local storage required for temporary EmptyDir volume (`/tmp`). Default value is `5Mi`.
                      enableServiceLinks:
                        type: boolean
                        description: Indicates whether information about services should be injected into Pod's environment variables.
                      topologySpreadConstraints:
                        type: array
                        items:
                          type: object
                          properties:
                            labelSelector:
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
                            matchLabelKeys:
                              type: array
                              items:
                                type: string
                            maxSkew:
                              type: integer
                            minDomains:
                              type: integer
                            nodeAffinityPolicy:
                              type: string
                            nodeTaintsPolicy:
                              type: string
                            topologyKey:
                              type: string
                            whenUnsatisfiable:
                              type: string
                        description: The pod's topology spread constraints.
                    description: Template for Kafka `Pods`.
                  perPodService:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                    description: Template for Kafka per-pod `Services` used for access from outside of Kubernetes.
                  perPodRoute:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                    description: Template for Kafka per-pod `Routes` used for access from outside of OpenShift.
                  perPodIngress:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                    description: Template for Kafka per-pod `Ingress` used for access from outside of Kubernetes.
                  persistentVolumeClaim:
                    type: object
                    properties:
                      metadata:
                        type: object
                        properties:
                          labels:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Labels added to the Kubernetes resource.
                          annotations:
                            x-kubernetes-preserve-unknown-fields: true
                            type: object
                            description: Annotations added to the Kubernetes resource.
                        description: Metadata applied to the resource.
                    description: Template for all Kafka `PersistentVolumeClaims`.
                  kafkaContainer:
                    type: object
                    properties:
                      env:
                        type: array
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              description: The environment variable key.
                            value:
                              type: string
                              description: The environment variable value.
                        description: Environment variables which should be applied to the container.
                      securityContext:
                        type: object
                        properties:
                          allowPrivilegeEscalation:
                            type: boolean
                          capabilities:
                            type: object
                            properties:
                              add:
                                type: array
                                items:
                                  type: string
                              drop:
                                type: array
                                items:
                                  type: string
                          privileged:
                            type: boolean
                          procMount:
                            type: string
                          readOnlyRootFilesystem:
                            type: boolean
                          runAsGroup:
                            type: integer
                          runAsNonRoot:
                            type: boolean
                          runAsUser:
                            type: integer
                          seLinuxOptions:
                            type: object
                            properties:
                              level:
                                type: string
                              role:
                                type: string
                              type:
                                type: string
                              user:
                                type: string
                          seccompProfile:
                            type: object
                            properties:
                              localhostProfile:
                                type: string
                              type:
                                type: string
                          windowsOptions:
                            type: object
                            properties:
                              gmsaCredentialSpec:
                                type: string
                              gmsaCredentialSpecName:
                                type: string
                              hostProcess:
                                type: boolean
                              runAsUserName:
                                type: string
                        description: Security context for the container.
                    description: Template for the Kafka broker container.
                  initContainer:
                    type: object
                    properties:
                      env:
                        type: array
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              description: The environment variable key.
                            value:
                              type: string
                              description: The environment variable value.
                        description: Environment variables which should be applied to the container.
                      securityContext:
                        type: object
                        properties:
                          allowPrivilegeEscalation:
                            type: boolean
                          capabilities:
                            type: object
                            properties:
                              add:
                                type: array
                                items:
                                  type: string
                              drop:
                                type: array
                                items:
                                  type: string
                          privileged:
                            type: boolean
                          procMount:
                            type: string
                          readOnlyRootFilesystem:
                            type: boolean
                          runAsGroup:
                            type: integer
                          runAsNonRoot:
                            type: boolean
                          runAsUser:
                            type: integer
                          seLinuxOptions:
                            type: object
                            properties:
                              level:
                                type: string
                              role:
                                type: string
                              type:
                                type: string
                              user:
                                type: string
                          seccompProfile:
                            type: object
                            properties:
                              localhostProfile:
                                type: string
                              type:
                                type: string
                          windowsOptions:
                            type: object
                            properties:
                              gmsaCredentialSpec:
                                type: string
                              gmsaCredentialSpecName:
                                type: string
                              hostProcess:
                                type: boolean
                              runAsUserName:
                                type: string
                        description: Security context for the container.
                    description: Template for the Kafka init container.
                description: Template for pool resources. The template allows users to specify how the resources belonging to this pool are generated.
            required:
            - replicas
            - storage
            - roles
            description: The specification of the KafkaNodePool.
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
              nodeIds:
                type: array
                items:
                  type: integer
                description: Node IDs used by Kafka nodes in this pool.
              clusterId:
                type: string
                description: Kafka cluster ID.
              replicas:
                type: integer
                description: The current number of pods being used to provide this resource.
              labelSelector:
                type: string
                description: Label selector for pods providing this resource.
            description: The status of the KafkaNodePool.
    YAML
)
}
