# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/046-Crd-kafkabridge.yaml

resource "kubernetes_manifest" "kafkabridges-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkabridges.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: kafkabridges.kafka.strimzi.io-crd
spec:
  group: kafka.strimzi.io
  names:
    kind: KafkaBridge
    listKind: KafkaBridgeList
    singular: kafkabridge
    plural: kafkabridges
    shortNames:
      - kb
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
          description: The desired number of Kafka Bridge replicas
          jsonPath: .spec.replicas
          type: integer
        - name: Bootstrap Servers
          description: The boostrap servers
          jsonPath: .spec.bootstrapServers
          type: string
          priority: 1
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
                  description: The number of pods in the `Deployment`.  Defaults to `1`.
                image:
                  type: string
                  description: The docker image for the pods.
                bootstrapServers:
                  type: string
                  description: A list of host:port pairs for establishing the initial connection to the Kafka cluster.
                tls:
                  type: object
                  properties:
                    trustedCertificates:
                      type: array
                      items:
                        type: object
                        properties:
                          certificate:
                            type: string
                            description: The name of the file certificate in the Secret.
                          secretName:
                            type: string
                            description: The name of the Secret containing the certificate.
                        required:
                          - certificate
                          - secretName
                      description: Trusted certificates for TLS connection.
                  description: TLS configuration for connecting Kafka Bridge to the cluster.
                authentication:
                  type: object
                  properties:
                    accessToken:
                      type: object
                      properties:
                        key:
                          type: string
                          description: The key under which the secret value is stored in the Kubernetes Secret.
                        secretName:
                          type: string
                          description: The name of the Kubernetes Secret containing the secret value.
                      required:
                        - key
                        - secretName
                      description: Link to Kubernetes Secret containing the access token which was obtained from the authorization server.
                    accessTokenIsJwt:
                      type: boolean
                      description: Configure whether access token should be treated as JWT. This should be set to `false` if the authorization server returns opaque tokens. Defaults to `true`.
                    audience:
                      type: string
                      description: "OAuth audience to use when authenticating against the authorization server. Some authorization servers require the audience to be explicitly set. The possible values depend on how the authorization server is configured. By default, `audience` is not specified when performing the token endpoint request."
                    certificateAndKey:
                      type: object
                      properties:
                        certificate:
                          type: string
                          description: The name of the file certificate in the Secret.
                        key:
                          type: string
                          description: The name of the private key in the Secret.
                        secretName:
                          type: string
                          description: The name of the Secret containing the certificate.
                      required:
                        - certificate
                        - key
                        - secretName
                      description: Reference to the `Secret` which holds the certificate and private key pair.
                    clientId:
                      type: string
                      description: OAuth Client ID which the Kafka client can use to authenticate against the OAuth server and use the token endpoint URI.
                    clientSecret:
                      type: object
                      properties:
                        key:
                          type: string
                          description: The key under which the secret value is stored in the Kubernetes Secret.
                        secretName:
                          type: string
                          description: The name of the Kubernetes Secret containing the secret value.
                      required:
                        - key
                        - secretName
                      description: Link to Kubernetes Secret containing the OAuth client secret which the Kafka client can use to authenticate against the OAuth server and use the token endpoint URI.
                    connectTimeoutSeconds:
                      type: integer
                      description: "The connect timeout in seconds when connecting to authorization server. If not set, the effective connect timeout is 60 seconds."
                    disableTlsHostnameVerification:
                      type: boolean
                      description: Enable or disable TLS hostname verification. Default value is `false`.
                    enableMetrics:
                      type: boolean
                      description: Enable or disable OAuth metrics. Default value is `false`.
                    httpRetries:
                      type: integer
                      description: "The maximum number of retries to attempt if an initial HTTP request fails. If not set, the default is to not attempt any retries."
                    httpRetryPauseMs:
                      type: integer
                      description: "The pause to take before retrying a failed HTTP request. If not set, the default is to not pause at all but to immediately repeat a request."
                    maxTokenExpirySeconds:
                      type: integer
                      description: Set or limit time-to-live of the access tokens to the specified number of seconds. This should be set if the authorization server returns opaque tokens.
                    passwordSecret:
                      type: object
                      properties:
                        password:
                          type: string
                          description: The name of the key in the Secret under which the password is stored.
                        secretName:
                          type: string
                          description: The name of the Secret containing the password.
                      required:
                        - password
                        - secretName
                      description: Reference to the `Secret` which holds the password.
                    readTimeoutSeconds:
                      type: integer
                      description: "The read timeout in seconds when connecting to authorization server. If not set, the effective read timeout is 60 seconds."
                    refreshToken:
                      type: object
                      properties:
                        key:
                          type: string
                          description: The key under which the secret value is stored in the Kubernetes Secret.
                        secretName:
                          type: string
                          description: The name of the Kubernetes Secret containing the secret value.
                      required:
                        - key
                        - secretName
                      description: Link to Kubernetes Secret containing the refresh token which can be used to obtain access token from the authorization server.
                    scope:
                      type: string
                      description: OAuth scope to use when authenticating against the authorization server. Some authorization servers require this to be set. The possible values depend on how authorization server is configured. By default `scope` is not specified when doing the token endpoint request.
                    tlsTrustedCertificates:
                      type: array
                      items:
                        type: object
                        properties:
                          certificate:
                            type: string
                            description: The name of the file certificate in the Secret.
                          secretName:
                            type: string
                            description: The name of the Secret containing the certificate.
                        required:
                          - certificate
                          - secretName
                      description: Trusted certificates for TLS connection to the OAuth server.
                    tokenEndpointUri:
                      type: string
                      description: Authorization server token endpoint URI.
                    type:
                      type: string
                      enum:
                        - tls
                        - scram-sha-256
                        - scram-sha-512
                        - plain
                        - oauth
                      description: "Authentication type. Currently the supported types are `tls`, `scram-sha-256`, `scram-sha-512`, `plain`, and 'oauth'. `scram-sha-256` and `scram-sha-512` types use SASL SCRAM-SHA-256 and SASL SCRAM-SHA-512 Authentication, respectively. `plain` type uses SASL PLAIN Authentication. `oauth` type uses SASL OAUTHBEARER Authentication. The `tls` type uses TLS Client Authentication. The `tls` type is supported only over TLS connections."
                    username:
                      type: string
                      description: Username used for the authentication.
                  required:
                    - type
                  description: Authentication configuration for connecting to the cluster.
                http:
                  type: object
                  properties:
                    port:
                      type: integer
                      minimum: 1023
                      description: The port which is the server listening on.
                    cors:
                      type: object
                      properties:
                        allowedOrigins:
                          type: array
                          items:
                            type: string
                          description: List of allowed origins. Java regular expressions can be used.
                        allowedMethods:
                          type: array
                          items:
                            type: string
                          description: List of allowed HTTP methods.
                      required:
                        - allowedOrigins
                        - allowedMethods
                      description: CORS configuration for the HTTP Bridge.
                  description: The HTTP related configuration.
                adminClient:
                  type: object
                  properties:
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: The Kafka AdminClient configuration used for AdminClient instances created by the bridge.
                  description: Kafka AdminClient related configuration.
                consumer:
                  type: object
                  properties:
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: "The Kafka consumer configuration used for consumer instances created by the bridge. Properties with the following prefixes cannot be set: ssl., bootstrap.servers, group.id, sasl., security. (with the exception of: ssl.endpoint.identification.algorithm, ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols)."
                  description: Kafka consumer related configuration.
                producer:
                  type: object
                  properties:
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: "The Kafka producer configuration used for producer instances created by the bridge. Properties with the following prefixes cannot be set: ssl., bootstrap.servers, sasl., security. (with the exception of: ssl.endpoint.identification.algorithm, ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols)."
                  description: Kafka producer related configuration.
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
                  description: '**Currently not supported** JVM Options for pods.'
                logging:
                  type: object
                  properties:
                    loggers:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: A Map from logger name to logger level.
                    type:
                      type: string
                      enum:
                        - inline
                        - external
                      description: "Logging type, must be either 'inline' or 'external'."
                    valueFrom:
                      type: object
                      properties:
                        configMapKeyRef:
                          type: object
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          description: Reference to the key in the ConfigMap containing the configuration.
                      description: '`ConfigMap` entry where the logging configuration is stored. '
                  required:
                    - type
                  description: Logging configuration for Kafka Bridge.
                clientRackInitImage:
                  type: string
                  description: The image of the init container used for initializing the `client.rack`.
                rack:
                  type: object
                  properties:
                    topologyKey:
                      type: string
                      example: topology.kubernetes.io/zone
                      description: "A key that matches labels assigned to the Kubernetes cluster nodes. The value of the label is used to set a broker's `broker.rack` config, and the `client.rack` config for Kafka Connect or MirrorMaker 2."
                  required:
                    - topologyKey
                  description: Configuration of the node label which will be used as the client.rack consumer configuration.
                enableMetrics:
                  type: boolean
                  description: Enable the metrics for the Kafka Bridge. Default is false.
                livenessProbe:
                  type: object
                  properties:
                    failureThreshold:
                      type: integer
                      minimum: 1
                      description: Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.
                    initialDelaySeconds:
                      type: integer
                      minimum: 0
                      description: The initial delay before first the health is first checked. Default to 15 seconds. Minimum value is 0.
                    periodSeconds:
                      type: integer
                      minimum: 1
                      description: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
                    successThreshold:
                      type: integer
                      minimum: 1
                      description: Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness. Minimum value is 1.
                    timeoutSeconds:
                      type: integer
                      minimum: 1
                      description: The timeout for each attempted health check. Default to 5 seconds. Minimum value is 1.
                  description: Pod liveness checking.
                readinessProbe:
                  type: object
                  properties:
                    failureThreshold:
                      type: integer
                      minimum: 1
                      description: Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3. Minimum value is 1.
                    initialDelaySeconds:
                      type: integer
                      minimum: 0
                      description: The initial delay before first the health is first checked. Default to 15 seconds. Minimum value is 0.
                    periodSeconds:
                      type: integer
                      minimum: 1
                      description: How often (in seconds) to perform the probe. Default to 10 seconds. Minimum value is 1.
                    successThreshold:
                      type: integer
                      minimum: 1
                      description: Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness. Minimum value is 1.
                    timeoutSeconds:
                      type: integer
                      minimum: 1
                      description: The timeout for each attempted health check. Default to 5 seconds. Minimum value is 1.
                  description: Pod readiness checking.
                template:
                  type: object
                  properties:
                    deployment:
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
                        deploymentStrategy:
                          type: string
                          enum:
                            - RollingUpdate
                            - Recreate
                          description: Pod replacement strategy for deployment configuration changes. Valid values are `RollingUpdate` and `Recreate`. Defaults to `RollingUpdate`.
                      description: Template for Kafka Bridge `Deployment`.
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
                      description: Template for Kafka Bridge `Pods`.
                    apiService:
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
                        ipFamilyPolicy:
                          type: string
                          enum:
                            - SingleStack
                            - PreferDualStack
                            - RequireDualStack
                          description: "Specifies the IP Family Policy used by the service. Available options are `SingleStack`, `PreferDualStack` and `RequireDualStack`. `SingleStack` is for a single IP family. `PreferDualStack` is for two IP families on dual-stack configured clusters or a single IP family on single-stack clusters. `RequireDualStack` fails unless there are two IP families on dual-stack configured clusters. If unspecified, Kubernetes will choose the default value based on the service type."
                        ipFamilies:
                          type: array
                          items:
                            type: string
                            enum:
                              - IPv4
                              - IPv6
                          description: "Specifies the IP Families used by the service. Available options are `IPv4` and `IPv6`. If unspecified, Kubernetes will choose the default value based on the `ipFamilyPolicy` setting."
                      description: Template for Kafka Bridge API `Service`.
                    podDisruptionBudget:
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
                          description: Metadata to apply to the `PodDisruptionBudgetTemplate` resource.
                        maxUnavailable:
                          type: integer
                          minimum: 0
                          description: "Maximum number of unavailable pods to allow automatic Pod eviction. A Pod eviction is allowed when the `maxUnavailable` number of pods or fewer are unavailable after the eviction. Setting this value to 0 prevents all voluntary evictions, so the pods must be evicted manually. Defaults to 1."
                      description: Template for Kafka Bridge `PodDisruptionBudget`.
                    bridgeContainer:
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
                      description: Template for the Kafka Bridge container.
                    clusterRoleBinding:
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
                      description: Template for the Kafka Bridge ClusterRoleBinding.
                    serviceAccount:
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
                      description: Template for the Kafka Bridge service account.
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
                      description: Template for the Kafka Bridge init container.
                  description: Template for Kafka Bridge resources. The template allows users to specify how a `Deployment` and `Pod` is generated.
                tracing:
                  type: object
                  properties:
                    type:
                      type: string
                      enum:
                        - jaeger
                        - opentelemetry
                      description: "Type of the tracing used. Currently the only supported type is `opentelemetry` for OpenTelemetry tracing. As of Strimzi 0.37.0, `jaeger` type is not supported anymore and this option is ignored."
                  required:
                    - type
                  description: The configuration of tracing in Kafka Bridge.
              required:
                - bootstrapServers
              description: The specification of the Kafka Bridge.
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
                url:
                  type: string
                  description: The URL at which external client applications can access the Kafka Bridge.
                labelSelector:
                  type: string
                  description: Label selector for pods providing this resource.
                replicas:
                  type: integer
                  description: The current number of pods being used to provide this resource.
              description: The status of the Kafka Bridge.
  YAML
)
}
