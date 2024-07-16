# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/crds/040-Crd-kafka.yaml

resource "kubernetes_manifest" "kafkas-kafka-strimzi-io" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: kafkas.kafka.strimzi.io
  labels:
    app: strimzi
    strimzi.io/crd-install: "true"
    component: kafkas.kafka.strimzi.io-crd
spec:
  group: kafka.strimzi.io
  names:
    kind: Kafka
    listKind: KafkaList
    singular: kafka
    plural: kafkas
    shortNames:
      - k
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
        - name: Desired Kafka replicas
          description: The desired number of Kafka replicas in the cluster
          jsonPath: .spec.kafka.replicas
          type: integer
        - name: Desired ZK replicas
          description: The desired number of ZooKeeper replicas in the cluster
          jsonPath: .spec.zookeeper.replicas
          type: integer
        - name: Ready
          description: The state of the custom resource
          jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
          type: string
        - name: Warnings
          description: Warnings related to the custom resource
          jsonPath: ".status.conditions[?(@.type==\"Warning\")].status"
          type: string
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                kafka:
                  type: object
                  properties:
                    version:
                      type: string
                      description: "The kafka broker version. Defaults to {DefaultKafkaVersion}. Consult the user documentation to understand the process required to upgrade or downgrade the version."
                    replicas:
                      type: integer
                      minimum: 1
                      description: The number of pods in the cluster.
                    image:
                      type: string
                      description: The docker image for the pods. The default value depends on the configured `Kafka.spec.kafka.version`.
                    listeners:
                      type: array
                      minItems: 1
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                            pattern: "^[a-z0-9]{1,11}$"
                            description: Name of the listener. The name will be used to identify the listener and the related Kubernetes objects. The name has to be unique within given a Kafka cluster. The name can consist of lowercase characters and numbers and be up to 11 characters long.
                          port:
                            type: integer
                            minimum: 9092
                            description: "Port number used by the listener inside Kafka. The port number has to be unique within a given Kafka cluster. Allowed port numbers are 9092 and higher with the exception of ports 9404 and 9999, which are already used for Prometheus and JMX. Depending on the listener type, the port number might not be the same as the port number that connects Kafka clients."
                          type:
                            type: string
                            enum:
                              - internal
                              - route
                              - loadbalancer
                              - nodeport
                              - ingress
                              - cluster-ip
                            description: "Type of the listener. Currently the supported types are `internal`, `route`, `loadbalancer`, `nodeport` and `ingress`. \n\n* `internal` type exposes Kafka internally only within the Kubernetes cluster.\n* `route` type uses OpenShift Routes to expose Kafka.\n* `loadbalancer` type uses LoadBalancer type services to expose Kafka.\n* `nodeport` type uses NodePort type services to expose Kafka.\n* `ingress` type uses Kubernetes Nginx Ingress to expose Kafka with TLS passthrough.\n* `cluster-ip` type uses a per-broker `ClusterIP` service.\n"
                          tls:
                            type: boolean
                            description: Enables TLS encryption on the listener. This is a required property.
                          authentication:
                            type: object
                            properties:
                              accessTokenIsJwt:
                                type: boolean
                                description: Configure whether the access token is treated as JWT. This must be set to `false` if the authorization server returns opaque tokens. Defaults to `true`.
                              checkAccessTokenType:
                                type: boolean
                                description: Configure whether the access token type check is performed or not. This should be set to `false` if the authorization server does not include 'typ' claim in JWT token. Defaults to `true`.
                              checkAudience:
                                type: boolean
                                description: "Enable or disable audience checking. Audience checks identify the recipients of tokens. If audience checking is enabled, the OAuth Client ID also has to be configured using the `clientId` property. The Kafka broker will reject tokens that do not have its `clientId` in their `aud` (audience) claim.Default value is `false`."
                              checkIssuer:
                                type: boolean
                                description: Enable or disable issuer checking. By default issuer is checked using the value configured by `validIssuerUri`. Default value is `true`.
                              clientAudience:
                                type: string
                                description: The audience to use when making requests to the authorization server's token endpoint. Used for inter-broker authentication and for configuring OAuth 2.0 over PLAIN using the `clientId` and `secret` method.
                              clientId:
                                type: string
                                description: OAuth Client ID which the Kafka broker can use to authenticate against the authorization server and use the introspect endpoint URI.
                              clientScope:
                                type: string
                                description: The scope to use when making requests to the authorization server's token endpoint. Used for inter-broker authentication and for configuring OAuth 2.0 over PLAIN using the `clientId` and `secret` method.
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
                                description: Link to Kubernetes Secret containing the OAuth client secret which the Kafka broker can use to authenticate against the authorization server and use the introspect endpoint URI.
                              connectTimeoutSeconds:
                                type: integer
                                description: "The connect timeout in seconds when connecting to authorization server. If not set, the effective connect timeout is 60 seconds."
                              customClaimCheck:
                                type: string
                                description: JsonPath filter query to be applied to the JWT token or to the response of the introspection endpoint for additional token validation. Not set by default.
                              disableTlsHostnameVerification:
                                type: boolean
                                description: Enable or disable TLS hostname verification. Default value is `false`.
                              enableECDSA:
                                type: boolean
                                description: Enable or disable ECDSA support by installing BouncyCastle crypto provider. ECDSA support is always enabled. The BouncyCastle libraries are no longer packaged with Strimzi. Value is ignored.
                              enableMetrics:
                                type: boolean
                                description: Enable or disable OAuth metrics. Default value is `false`.
                              enableOauthBearer:
                                type: boolean
                                description: Enable or disable OAuth authentication over SASL_OAUTHBEARER. Default value is `true`.
                              enablePlain:
                                type: boolean
                                description: Enable or disable OAuth authentication over SASL_PLAIN. There is no re-authentication support when this mechanism is used. Default value is `false`.
                              failFast:
                                type: boolean
                                description: Enable or disable termination of Kafka broker processes due to potentially recoverable runtime errors during startup. Default value is `true`.
                              fallbackUserNameClaim:
                                type: string
                                description: The fallback username claim to be used for the user id if the claim specified by `userNameClaim` is not present. This is useful when `client_credentials` authentication only results in the client id being provided in another claim. It only takes effect if `userNameClaim` is set.
                              fallbackUserNamePrefix:
                                type: string
                                description: "The prefix to use with the value of `fallbackUserNameClaim` to construct the user id. This only takes effect if `fallbackUserNameClaim` is true, and the value is present for the claim. Mapping usernames and client ids into the same user id space is useful in preventing name collisions."
                              groupsClaim:
                                type: string
                                description: JsonPath query used to extract groups for the user during authentication. Extracted groups can be used by a custom authorizer. By default no groups are extracted.
                              groupsClaimDelimiter:
                                type: string
                                description: "A delimiter used to parse groups when they are extracted as a single String value rather than a JSON array. Default value is ',' (comma)."
                              httpRetries:
                                type: integer
                                description: "The maximum number of retries to attempt if an initial HTTP request fails. If not set, the default is to not attempt any retries."
                              httpRetryPauseMs:
                                type: integer
                                description: "The pause to take before retrying a failed HTTP request. If not set, the default is to not pause at all but to immediately repeat a request."
                              introspectionEndpointUri:
                                type: string
                                description: URI of the token introspection endpoint which can be used to validate opaque non-JWT tokens.
                              jwksEndpointUri:
                                type: string
                                description: "URI of the JWKS certificate endpoint, which can be used for local JWT validation."
                              jwksExpirySeconds:
                                type: integer
                                minimum: 1
                                description: Configures how often are the JWKS certificates considered valid. The expiry interval has to be at least 60 seconds longer then the refresh interval specified in `jwksRefreshSeconds`. Defaults to 360 seconds.
                              jwksIgnoreKeyUse:
                                type: boolean
                                description: Flag to ignore the 'use' attribute of `key` declarations in a JWKS endpoint response. Default value is `false`.
                              jwksMinRefreshPauseSeconds:
                                type: integer
                                minimum: 0
                                description: "The minimum pause between two consecutive refreshes. When an unknown signing key is encountered the refresh is scheduled immediately, but will always wait for this minimum pause. Defaults to 1 second."
                              jwksRefreshSeconds:
                                type: integer
                                minimum: 1
                                description: Configures how often are the JWKS certificates refreshed. The refresh interval has to be at least 60 seconds shorter then the expiry interval specified in `jwksExpirySeconds`. Defaults to 300 seconds.
                              listenerConfig:
                                x-kubernetes-preserve-unknown-fields: true
                                type: object
                                description: Configuration to be used for a specific listener. All values are prefixed with listener.name._<listener_name>_.
                              maxSecondsWithoutReauthentication:
                                type: integer
                                description: "Maximum number of seconds the authenticated session remains valid without re-authentication. This enables Apache Kafka re-authentication feature, and causes sessions to expire when the access token expires. If the access token expires before max time or if max time is reached, the client has to re-authenticate, otherwise the server will drop the connection. Not set by default - the authenticated session does not expire when the access token expires. This option only applies to SASL_OAUTHBEARER authentication mechanism (when `enableOauthBearer` is `true`)."
                              readTimeoutSeconds:
                                type: integer
                                description: "The read timeout in seconds when connecting to authorization server. If not set, the effective read timeout is 60 seconds."
                              sasl:
                                type: boolean
                                description: Enable or disable SASL on this listener.
                              secrets:
                                type: array
                                items:
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
                                description: Secrets to be mounted to /opt/kafka/custom-authn-secrets/custom-listener-_<listener_name>-<port>_/_<secret_name>_.
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
                                description: "URI of the Token Endpoint to use with SASL_PLAIN mechanism when the client authenticates with `clientId` and a `secret`. If set, the client can authenticate over SASL_PLAIN by either setting `username` to `clientId`, and setting `password` to client `secret`, or by setting `username` to account username, and `password` to access token prefixed with `$accessToken:`. If this option is not set, the `password` is always interpreted as an access token (without a prefix), and `username` as the account username (a so called 'no-client-credentials' mode)."
                              type:
                                type: string
                                enum:
                                  - tls
                                  - scram-sha-512
                                  - oauth
                                  - custom
                                description: Authentication type. `oauth` type uses SASL OAUTHBEARER Authentication. `scram-sha-512` type uses SASL SCRAM-SHA-512 Authentication. `tls` type uses TLS Client Authentication. `tls` type is supported only on TLS listeners.`custom` type allows for any authentication type to be used.
                              userInfoEndpointUri:
                                type: string
                                description: 'URI of the User Info Endpoint to use as a fallback to obtaining the user id when the Introspection Endpoint does not return information that can be used for the user id. '
                              userNameClaim:
                                type: string
                                description: "Name of the claim from the JWT authentication token, Introspection Endpoint response or User Info Endpoint response which will be used to extract the user id. Defaults to `sub`."
                              validIssuerUri:
                                type: string
                                description: URI of the token issuer used for authentication.
                              validTokenType:
                                type: string
                                description: "Valid value for the `token_type` attribute returned by the Introspection Endpoint. No default value, and not checked by default."
                            required:
                              - type
                            description: Authentication configuration for this listener.
                          configuration:
                            type: object
                            properties:
                              brokerCertChainAndKey:
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
                                description: Reference to the `Secret` which holds the certificate and private key pair which will be used for this listener. The certificate can optionally contain the whole chain. This field can be used only with listeners with enabled TLS encryption.
                              externalTrafficPolicy:
                                type: string
                                enum:
                                  - Local
                                  - Cluster
                                description: "Specifies whether the service routes external traffic to node-local or cluster-wide endpoints. `Cluster` may cause a second hop to another node and obscures the client source IP. `Local` avoids a second hop for LoadBalancer and Nodeport type services and preserves the client source IP (when supported by the infrastructure). If unspecified, Kubernetes will use `Cluster` as the default.This field can be used only with `loadbalancer` or `nodeport` type listener."
                              loadBalancerSourceRanges:
                                type: array
                                items:
                                  type: string
                                description: "A list of CIDR ranges (for example `10.0.0.0/8` or `130.211.204.1/32`) from which clients can connect to load balancer type listeners. If supported by the platform, traffic through the loadbalancer is restricted to the specified CIDR ranges. This field is applicable only for loadbalancer type services and is ignored if the cloud provider does not support the feature. This field can be used only with `loadbalancer` type listener."
                              bootstrap:
                                type: object
                                properties:
                                  alternativeNames:
                                    type: array
                                    items:
                                      type: string
                                    description: Additional alternative names for the bootstrap service. The alternative names will be added to the list of subject alternative names of the TLS certificates.
                                  host:
                                    type: string
                                    description: The bootstrap host. This field will be used in the Ingress resource or in the Route resource to specify the desired hostname. This field can be used only with `route` (optional) or `ingress` (required) type listeners.
                                  nodePort:
                                    type: integer
                                    description: Node port for the bootstrap service. This field can be used only with `nodeport` type listener.
                                  loadBalancerIP:
                                    type: string
                                    description: The loadbalancer is requested with the IP address specified in this field. This feature depends on whether the underlying cloud provider supports specifying the `loadBalancerIP` when a load balancer is created. This field is ignored if the cloud provider does not support the feature.This field can be used only with `loadbalancer` type listener.
                                  annotations:
                                    x-kubernetes-preserve-unknown-fields: true
                                    type: object
                                    description: "Annotations that will be added to the `Ingress`, `Route`, or `Service` resource. You can use this field to configure DNS providers such as External DNS. This field can be used only with `loadbalancer`, `nodeport`, `route`, or `ingress` type listeners."
                                  labels:
                                    x-kubernetes-preserve-unknown-fields: true
                                    type: object
                                    description: "Labels that will be added to the `Ingress`, `Route`, or `Service` resource. This field can be used only with `loadbalancer`, `nodeport`, `route`, or `ingress` type listeners."
                                description: Bootstrap configuration.
                              brokers:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    broker:
                                      type: integer
                                      description: ID of the kafka broker (broker identifier). Broker IDs start from 0 and correspond to the number of broker replicas.
                                    advertisedHost:
                                      type: string
                                      description: The host name used in the brokers' `advertised.listeners`.
                                    advertisedPort:
                                      type: integer
                                      description: The port number used in the brokers' `advertised.listeners`.
                                    host:
                                      type: string
                                      description: The broker host. This field will be used in the Ingress resource or in the Route resource to specify the desired hostname. This field can be used only with `route` (optional) or `ingress` (required) type listeners.
                                    nodePort:
                                      type: integer
                                      description: Node port for the per-broker service. This field can be used only with `nodeport` type listener.
                                    loadBalancerIP:
                                      type: string
                                      description: The loadbalancer is requested with the IP address specified in this field. This feature depends on whether the underlying cloud provider supports specifying the `loadBalancerIP` when a load balancer is created. This field is ignored if the cloud provider does not support the feature.This field can be used only with `loadbalancer` type listener.
                                    annotations:
                                      x-kubernetes-preserve-unknown-fields: true
                                      type: object
                                      description: "Annotations that will be added to the `Ingress` or `Service` resource. You can use this field to configure DNS providers such as External DNS. This field can be used only with `loadbalancer`, `nodeport`, or `ingress` type listeners."
                                    labels:
                                      x-kubernetes-preserve-unknown-fields: true
                                      type: object
                                      description: "Labels that will be added to the `Ingress`, `Route`, or `Service` resource. This field can be used only with `loadbalancer`, `nodeport`, `route`, or `ingress` type listeners."
                                  required:
                                    - broker
                                description: Per-broker configurations.
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
                              createBootstrapService:
                                type: boolean
                                description: Whether to create the bootstrap service or not. The bootstrap service is created by default (if not specified differently). This field can be used with the `loadBalancer` type listener.
                              class:
                                type: string
                                description: "Configures a specific class for `Ingress` and `LoadBalancer` that defines which controller will be used. This field can only be used with `ingress` and `loadbalancer` type listeners. If not specified, the default controller is used. For an `ingress` listener, set the `ingressClassName` property in the `Ingress` resources. For a `loadbalancer` listener, set the `loadBalancerClass` property  in the `Service` resources."
                              finalizers:
                                type: array
                                items:
                                  type: string
                                description: "A list of finalizers which will be configured for the `LoadBalancer` type Services created for this listener. If supported by the platform, the finalizer `service.kubernetes.io/load-balancer-cleanup` to make sure that the external load balancer is deleted together with the service.For more information, see https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#garbage-collecting-load-balancers. This field can be used only with `loadbalancer` type listeners."
                              maxConnectionCreationRate:
                                type: integer
                                description: The maximum connection creation rate we allow in this listener at any time. New connections will be throttled if the limit is reached.
                              maxConnections:
                                type: integer
                                description: The maximum number of connections we allow for this listener in the broker at any time. New connections are blocked if the limit is reached.
                              preferredNodePortAddressType:
                                type: string
                                enum:
                                  - ExternalIP
                                  - ExternalDNS
                                  - InternalIP
                                  - InternalDNS
                                  - Hostname
                                description: |-
                                  Defines which address type should be used as the node address. Available types are: `ExternalDNS`, `ExternalIP`, `InternalDNS`, `InternalIP` and `Hostname`. By default, the addresses will be used in the following order (the first one found will be used):

                                  * `ExternalDNS`
                                  * `ExternalIP`
                                  * `InternalDNS`
                                  * `InternalIP`
                                  * `Hostname`

                                  This field is used to select the preferred address type, which is checked first. If no address is found for this address type, the other types are checked in the default order. This field can only be used with `nodeport` type listener.
                              useServiceDnsDomain:
                                type: boolean
                                description: "Configures whether the Kubernetes service DNS domain should be used or not. If set to `true`, the generated addresses will contain the service DNS domain suffix (by default `.cluster.local`, can be configured using environment variable `KUBERNETES_SERVICE_DNS_DOMAIN`). Defaults to `false`.This field can be used only with `internal` and `cluster-ip` type listeners."
                            description: Additional listener configuration.
                          networkPolicyPeers:
                            type: array
                            items:
                              type: object
                              properties:
                                ipBlock:
                                  type: object
                                  properties:
                                    cidr:
                                      type: string
                                    except:
                                      type: array
                                      items:
                                        type: string
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
                                podSelector:
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
                            description: "List of peers which should be able to connect to this listener. Peers in this list are combined using a logical OR operation. If this field is empty or missing, all connections will be allowed for this listener. If this field is present and contains at least one item, the listener only allows the traffic which matches at least one item in this list."
                        required:
                          - name
                          - port
                          - type
                          - tls
                      description: Configures listeners of Kafka brokers.
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: "Kafka broker config properties with the following prefixes cannot be set: listeners, advertised., broker., listener., host.name, port, inter.broker.listener.name, sasl., ssl., security., password., log.dir, zookeeper.connect, zookeeper.set.acl, zookeeper.ssl, zookeeper.clientCnxnSocket, authorizer., super.user, cruise.control.metrics.topic, cruise.control.metrics.reporter.bootstrap.servers,node.id, process.roles, controller., metadata.log.dir (with the exception of: zookeeper.connection.timeout.ms, sasl.server.max.receive.size,ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols, ssl.secure.random.implementation,cruise.control.metrics.topic.num.partitions, cruise.control.metrics.topic.replication.factor, cruise.control.metrics.topic.retention.ms,cruise.control.metrics.topic.auto.create.retries, cruise.control.metrics.topic.auto.create.timeout.ms,cruise.control.metrics.topic.min.insync.replicas,controller.quorum.election.backoff.max.ms, controller.quorum.election.timeout.ms, controller.quorum.fetch.timeout.ms)."
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
                    authorization:
                      type: object
                      properties:
                        allowOnError:
                          type: boolean
                          description: "Defines whether a Kafka client should be allowed or denied by default when the authorizer fails to query the Open Policy Agent, for example, when it is temporarily unavailable). Defaults to `false` - all actions will be denied."
                        authorizerClass:
                          type: string
                          description: "Authorization implementation class, which must be available in classpath."
                        clientId:
                          type: string
                          description: OAuth Client ID which the Kafka client can use to authenticate against the OAuth server and use the token endpoint URI.
                        connectTimeoutSeconds:
                          type: integer
                          minimum: 1
                          description: "The connect timeout in seconds when connecting to authorization server. If not set, the effective connect timeout is 60 seconds."
                        delegateToKafkaAcls:
                          type: boolean
                          description: Whether authorization decision should be delegated to the 'Simple' authorizer if DENIED by Keycloak Authorization Services policies. Default value is `false`.
                        disableTlsHostnameVerification:
                          type: boolean
                          description: Enable or disable TLS hostname verification. Default value is `false`.
                        enableMetrics:
                          type: boolean
                          description: Enable or disable OAuth metrics. The default value is `false`.
                        expireAfterMs:
                          type: integer
                          description: The expiration of the records kept in the local cache to avoid querying the Open Policy Agent for every request. Defines how often the cached authorization decisions are reloaded from the Open Policy Agent server. In milliseconds. Defaults to `3600000`.
                        grantsAlwaysLatest:
                          type: boolean
                          description: "Controls whether the latest grants are fetched for a new session. When enabled, grants are retrieved from Keycloak and cached for the user. The default value is `false`."
                        grantsGcPeriodSeconds:
                          type: integer
                          minimum: 1
                          description: "The time, in seconds, between consecutive runs of a job that cleans stale grants from the cache. The default value is 300."
                        grantsMaxIdleTimeSeconds:
                          type: integer
                          minimum: 1
                          description: "The time, in seconds, after which an idle grant can be evicted from the cache. The default value is 300."
                        grantsRefreshPeriodSeconds:
                          type: integer
                          minimum: 0
                          description: The time between two consecutive grants refresh runs in seconds. The default value is 60.
                        grantsRefreshPoolSize:
                          type: integer
                          minimum: 1
                          description: "The number of threads to use to refresh grants for active sessions. The more threads, the more parallelism, so the sooner the job completes. However, using more threads places a heavier load on the authorization server. The default value is 5."
                        httpRetries:
                          type: integer
                          minimum: 0
                          description: "The maximum number of retries to attempt if an initial HTTP request fails. If not set, the default is to not attempt any retries."
                        initialCacheCapacity:
                          type: integer
                          description: Initial capacity of the local cache used by the authorizer to avoid querying the Open Policy Agent for every request Defaults to `5000`.
                        maximumCacheSize:
                          type: integer
                          description: Maximum capacity of the local cache used by the authorizer to avoid querying the Open Policy Agent for every request. Defaults to `50000`.
                        readTimeoutSeconds:
                          type: integer
                          minimum: 1
                          description: "The read timeout in seconds when connecting to authorization server. If not set, the effective read timeout is 60 seconds."
                        superUsers:
                          type: array
                          items:
                            type: string
                          description: "List of super users, which are user principals with unlimited access rights."
                        supportsAdminApi:
                          type: boolean
                          description: Indicates whether the custom authorizer supports the APIs for managing ACLs using the Kafka Admin API. Defaults to `false`.
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
                            - simple
                            - opa
                            - keycloak
                            - custom
                          description: "Authorization type. Currently, the supported types are `simple`, `keycloak`, `opa` and `custom`. `simple` authorization type uses Kafka's `kafka.security.authorizer.AclAuthorizer` class for authorization. `keycloak` authorization type uses Keycloak Authorization Services for authorization. `opa` authorization type uses Open Policy Agent based authorization.`custom` authorization type uses user-provided implementation for authorization."
                        url:
                          type: string
                          example: http://opa:8181/v1/data/kafka/authz/allow
                          description: The URL used to connect to the Open Policy Agent server. The URL has to include the policy which will be queried by the authorizer. This option is required.
                      required:
                        - type
                      description: Authorization configuration for Kafka brokers.
                    rack:
                      type: object
                      properties:
                        topologyKey:
                          type: string
                          example: topology.kubernetes.io/zone
                          description: "A key that matches labels assigned to the Kubernetes cluster nodes. The value of the label is used to set a broker's `broker.rack` config, and the `client.rack` config for Kafka Connect or MirrorMaker 2."
                      required:
                        - topologyKey
                      description: Configuration of the `broker.rack` broker config.
                    brokerRackInitImage:
                      type: string
                      description: The image of the init container used for initializing the `broker.rack`.
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
                    jmxOptions:
                      type: object
                      properties:
                        authentication:
                          type: object
                          properties:
                            type:
                              type: string
                              enum:
                                - password
                              description: Authentication type. Currently the only supported types are `password`.`password` type creates a username and protected port with no TLS.
                          required:
                            - type
                          description: Authentication configuration for connecting to the JMX port.
                      description: JMX Options for Kafka brokers.
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
                    metricsConfig:
                      type: object
                      properties:
                        type:
                          type: string
                          enum:
                            - jmxPrometheusExporter
                          description: Metrics type. Only 'jmxPrometheusExporter' supported currently.
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
                          description: "ConfigMap entry where the Prometheus JMX Exporter configuration is stored. For details of the structure of this configuration, see the {JMXExporter}."
                      required:
                        - type
                        - valueFrom
                      description: Metrics configuration.
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
                      description: Logging configuration for Kafka.
                    template:
                      type: object
                      properties:
                        statefulset:
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
                            podManagementPolicy:
                              type: string
                              enum:
                                - OrderedReady
                                - Parallel
                              description: PodManagementPolicy which will be used for this StatefulSet. Valid values are `Parallel` and `OrderedReady`. Defaults to `Parallel`.
                          description: Template for Kafka `StatefulSet`.
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
                        bootstrapService:
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
                          description: Template for Kafka bootstrap `Service`.
                        brokersService:
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
                          description: Template for Kafka broker `Service`.
                        externalBootstrapService:
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
                          description: Template for Kafka external bootstrap `Service`.
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
                        externalBootstrapRoute:
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
                          description: Template for Kafka external bootstrap `Route`.
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
                        externalBootstrapIngress:
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
                          description: Template for Kafka external bootstrap `Ingress`.
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
                          description: Template for Kafka `PodDisruptionBudget`.
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
                        clusterCaCert:
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
                          description: Template for Secret with Kafka Cluster certificate public key.
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
                          description: Template for the Kafka service account.
                        jmxSecret:
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
                          description: Template for Secret of the Kafka Cluster JMX authentication.
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
                          description: Template for the Kafka ClusterRoleBinding.
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
                      description: Template for Kafka cluster resources. The template allows users to specify how the Kubernetes resources are generated.
                  required:
                    - replicas
                    - listeners
                    - storage
                  description: Configuration of the Kafka cluster.
                zookeeper:
                  type: object
                  properties:
                    replicas:
                      type: integer
                      minimum: 1
                      description: The number of pods in the cluster.
                    image:
                      type: string
                      description: The docker image for the pods.
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
                          description: "Storage type, must be either 'ephemeral' or 'persistent-claim'."
                      required:
                        - type
                      description: Storage configuration (disk). Cannot be updated.
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: "The ZooKeeper broker config. Properties with the following prefixes cannot be set: server., dataDir, dataLogDir, clientPort, authProvider, quorum.auth, requireClientAuthScheme, snapshot.trust.empty, standaloneEnabled, reconfigEnabled, 4lw.commands.whitelist, secureClientPort, ssl., serverCnxnFactory, sslQuorum (with the exception of: ssl.protocol, ssl.quorum.protocol, ssl.enabledProtocols, ssl.quorum.enabledProtocols, ssl.ciphersuites, ssl.quorum.ciphersuites, ssl.hostnameVerification, ssl.quorum.hostnameVerification)."
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
                    jmxOptions:
                      type: object
                      properties:
                        authentication:
                          type: object
                          properties:
                            type:
                              type: string
                              enum:
                                - password
                              description: Authentication type. Currently the only supported types are `password`.`password` type creates a username and protected port with no TLS.
                          required:
                            - type
                          description: Authentication configuration for connecting to the JMX port.
                      description: JMX Options for Zookeeper nodes.
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
                    metricsConfig:
                      type: object
                      properties:
                        type:
                          type: string
                          enum:
                            - jmxPrometheusExporter
                          description: Metrics type. Only 'jmxPrometheusExporter' supported currently.
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
                          description: "ConfigMap entry where the Prometheus JMX Exporter configuration is stored. For details of the structure of this configuration, see the {JMXExporter}."
                      required:
                        - type
                        - valueFrom
                      description: Metrics configuration.
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
                      description: Logging configuration for ZooKeeper.
                    template:
                      type: object
                      properties:
                        statefulset:
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
                            podManagementPolicy:
                              type: string
                              enum:
                                - OrderedReady
                                - Parallel
                              description: PodManagementPolicy which will be used for this StatefulSet. Valid values are `Parallel` and `OrderedReady`. Defaults to `Parallel`.
                          description: Template for ZooKeeper `StatefulSet`.
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
                          description: Template for ZooKeeper `Pods`.
                        clientService:
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
                          description: Template for ZooKeeper client `Service`.
                        nodesService:
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
                          description: Template for ZooKeeper nodes `Service`.
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
                          description: Template for all ZooKeeper `PersistentVolumeClaims`.
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
                          description: Template for ZooKeeper `PodDisruptionBudget`.
                        zookeeperContainer:
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
                          description: Template for the ZooKeeper container.
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
                          description: Template for the ZooKeeper service account.
                        jmxSecret:
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
                          description: Template for Secret of the Zookeeper Cluster JMX authentication.
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
                          description: Template for ZooKeeper `StrimziPodSet` resource.
                      description: Template for ZooKeeper cluster resources. The template allows users to specify how the Kubernetes resources are generated.
                  required:
                    - replicas
                    - storage
                  description: Configuration of the ZooKeeper cluster.
                entityOperator:
                  type: object
                  properties:
                    topicOperator:
                      type: object
                      properties:
                        watchedNamespace:
                          type: string
                          description: The namespace the Topic Operator should watch.
                        image:
                          type: string
                          description: The image to use for the Topic Operator.
                        reconciliationIntervalSeconds:
                          type: integer
                          minimum: 0
                          description: Interval between periodic reconciliations.
                        zookeeperSessionTimeoutSeconds:
                          type: integer
                          minimum: 0
                          description: Timeout for the ZooKeeper session.
                        startupProbe:
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
                          description: Pod startup checking.
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
                        topicMetadataMaxAttempts:
                          type: integer
                          minimum: 0
                          description: The number of attempts at getting topic metadata.
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
                          description: Logging configuration.
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
                      description: Configuration of the Topic Operator.
                    userOperator:
                      type: object
                      properties:
                        watchedNamespace:
                          type: string
                          description: The namespace the User Operator should watch.
                        image:
                          type: string
                          description: The image to use for the User Operator.
                        reconciliationIntervalSeconds:
                          type: integer
                          minimum: 0
                          description: Interval between periodic reconciliations.
                        zookeeperSessionTimeoutSeconds:
                          type: integer
                          minimum: 0
                          description: Timeout for the ZooKeeper session.
                        secretPrefix:
                          type: string
                          description: The prefix that will be added to the KafkaUser name to be used as the Secret name.
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
                          description: Logging configuration.
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
                      description: Configuration of the User Operator.
                    tlsSidecar:
                      type: object
                      properties:
                        image:
                          type: string
                          description: The docker image for the container.
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
                        logLevel:
                          type: string
                          enum:
                            - emerg
                            - alert
                            - crit
                            - err
                            - warning
                            - notice
                            - info
                            - debug
                          description: The log level for the TLS sidecar. Default value is `notice`.
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
                      description: TLS sidecar configuration.
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
                          description: Template for Entity Operator `Deployment`.
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
                          description: Template for Entity Operator `Pods`.
                        topicOperatorContainer:
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
                          description: Template for the Entity Topic Operator container.
                        userOperatorContainer:
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
                          description: Template for the Entity User Operator container.
                        tlsSidecarContainer:
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
                          description: Template for the Entity Operator TLS sidecar container.
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
                          description: Template for the Entity Operator service account.
                        entityOperatorRole:
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
                          description: Template for the Entity Operator Role.
                        topicOperatorRoleBinding:
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
                          description: Template for the Entity Topic Operator RoleBinding.
                        userOperatorRoleBinding:
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
                          description: Template for the Entity Topic Operator RoleBinding.
                      description: Template for Entity Operator resources. The template allows users to specify how a `Deployment` and `Pod` is generated.
                  description: Configuration of the Entity Operator.
                clusterCa:
                  type: object
                  properties:
                    generateCertificateAuthority:
                      type: boolean
                      description: If true then Certificate Authority certificates will be generated automatically. Otherwise the user will need to provide a Secret with the CA certificate. Default is true.
                    generateSecretOwnerReference:
                      type: boolean
                      description: "If `true`, the Cluster and Client CA Secrets are configured with the `ownerReference` set to the `Kafka` resource. If the `Kafka` resource is deleted when `true`, the CA Secrets are also deleted. If `false`, the `ownerReference` is disabled. If the `Kafka` resource is deleted when `false`, the CA Secrets are retained and available for reuse. Default is `true`."
                    validityDays:
                      type: integer
                      minimum: 1
                      description: The number of days generated certificates should be valid for. The default is 365.
                    renewalDays:
                      type: integer
                      minimum: 1
                      description: "The number of days in the certificate renewal period. This is the number of days before the a certificate expires during which renewal actions may be performed. When `generateCertificateAuthority` is true, this will cause the generation of a new certificate. When `generateCertificateAuthority` is true, this will cause extra logging at WARN level about the pending certificate expiry. Default is 30."
                    certificateExpirationPolicy:
                      type: string
                      enum:
                        - renew-certificate
                        - replace-key
                      description: How should CA certificate expiration be handled when `generateCertificateAuthority=true`. The default is for a new CA certificate to be generated reusing the existing private key.
                  description: Configuration of the cluster certificate authority.
                clientsCa:
                  type: object
                  properties:
                    generateCertificateAuthority:
                      type: boolean
                      description: If true then Certificate Authority certificates will be generated automatically. Otherwise the user will need to provide a Secret with the CA certificate. Default is true.
                    generateSecretOwnerReference:
                      type: boolean
                      description: "If `true`, the Cluster and Client CA Secrets are configured with the `ownerReference` set to the `Kafka` resource. If the `Kafka` resource is deleted when `true`, the CA Secrets are also deleted. If `false`, the `ownerReference` is disabled. If the `Kafka` resource is deleted when `false`, the CA Secrets are retained and available for reuse. Default is `true`."
                    validityDays:
                      type: integer
                      minimum: 1
                      description: The number of days generated certificates should be valid for. The default is 365.
                    renewalDays:
                      type: integer
                      minimum: 1
                      description: "The number of days in the certificate renewal period. This is the number of days before the a certificate expires during which renewal actions may be performed. When `generateCertificateAuthority` is true, this will cause the generation of a new certificate. When `generateCertificateAuthority` is true, this will cause extra logging at WARN level about the pending certificate expiry. Default is 30."
                    certificateExpirationPolicy:
                      type: string
                      enum:
                        - renew-certificate
                        - replace-key
                      description: How should CA certificate expiration be handled when `generateCertificateAuthority=true`. The default is for a new CA certificate to be generated reusing the existing private key.
                  description: Configuration of the clients certificate authority.
                cruiseControl:
                  type: object
                  properties:
                    image:
                      type: string
                      description: The docker image for the pods.
                    tlsSidecar:
                      type: object
                      properties:
                        image:
                          type: string
                          description: The docker image for the container.
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
                        logLevel:
                          type: string
                          enum:
                            - emerg
                            - alert
                            - crit
                            - err
                            - warning
                            - notice
                            - info
                            - debug
                          description: The log level for the TLS sidecar. Default value is `notice`.
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
                      description: TLS sidecar configuration.
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
                      description: CPU and memory resources to reserve for the Cruise Control container.
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
                      description: Pod liveness checking for the Cruise Control container.
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
                      description: Pod readiness checking for the Cruise Control container.
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
                      description: JVM Options for the Cruise Control container.
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
                      description: Logging configuration (Log4j 2) for Cruise Control.
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
                          description: Template for Cruise Control `Deployment`.
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
                          description: Template for Cruise Control `Pods`.
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
                          description: Template for Cruise Control API `Service`.
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
                          description: Template for Cruise Control `PodDisruptionBudget`.
                        cruiseControlContainer:
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
                          description: Template for the Cruise Control container.
                        tlsSidecarContainer:
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
                          description: Template for the Cruise Control TLS sidecar container.
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
                          description: Template for the Cruise Control service account.
                      description: "Template to specify how Cruise Control resources, `Deployments` and `Pods`, are generated."
                    brokerCapacity:
                      type: object
                      properties:
                        disk:
                          type: string
                          pattern: "^[0-9]+([.][0-9]*)?([KMGTPE]i?|e[0-9]+)?$"
                          description: "Broker capacity for disk in bytes. Use a number value with either standard Kubernetes byte units (K, M, G, or T), their bibyte (power of two) equivalents (Ki, Mi, Gi, or Ti), or a byte value with or without E notation. For example, 100000M, 100000Mi, 104857600000, or 1e+11."
                        cpuUtilization:
                          type: integer
                          minimum: 0
                          maximum: 100
                          description: Broker capacity for CPU resource utilization as a percentage (0 - 100).
                        cpu:
                          type: string
                          pattern: "^[0-9]+([.][0-9]{0,3}|[m]?)$"
                          description: "Broker capacity for CPU resource in cores or millicores. For example, 1, 1.500, 1500m. For more information on valid CPU resource units see https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu."
                        inboundNetwork:
                          type: string
                          pattern: "^[0-9]+([KMG]i?)?B/s$"
                          description: "Broker capacity for inbound network throughput in bytes per second. Use an integer value with standard Kubernetes byte units (K, M, G) or their bibyte (power of two) equivalents (Ki, Mi, Gi) per second. For example, 10000KiB/s."
                        outboundNetwork:
                          type: string
                          pattern: "^[0-9]+([KMG]i?)?B/s$"
                          description: "Broker capacity for outbound network throughput in bytes per second. Use an integer value with standard Kubernetes byte units (K, M, G) or their bibyte (power of two) equivalents (Ki, Mi, Gi) per second. For example, 10000KiB/s."
                        overrides:
                          type: array
                          items:
                            type: object
                            properties:
                              brokers:
                                type: array
                                items:
                                  type: integer
                                description: List of Kafka brokers (broker identifiers).
                              cpu:
                                type: string
                                pattern: "^[0-9]+([.][0-9]{0,3}|[m]?)$"
                                description: "Broker capacity for CPU resource in cores or millicores. For example, 1, 1.500, 1500m. For more information on valid CPU resource units see https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#meaning-of-cpu."
                              inboundNetwork:
                                type: string
                                pattern: "^[0-9]+([KMG]i?)?B/s$"
                                description: "Broker capacity for inbound network throughput in bytes per second. Use an integer value with standard Kubernetes byte units (K, M, G) or their bibyte (power of two) equivalents (Ki, Mi, Gi) per second. For example, 10000KiB/s."
                              outboundNetwork:
                                type: string
                                pattern: "^[0-9]+([KMG]i?)?B/s$"
                                description: "Broker capacity for outbound network throughput in bytes per second. Use an integer value with standard Kubernetes byte units (K, M, G) or their bibyte (power of two) equivalents (Ki, Mi, Gi) per second. For example, 10000KiB/s."
                            required:
                              - brokers
                          description: Overrides for individual brokers. The `overrides` property lets you specify a different capacity configuration for different brokers.
                      description: The Cruise Control `brokerCapacity` configuration.
                    config:
                      x-kubernetes-preserve-unknown-fields: true
                      type: object
                      description: "The Cruise Control configuration. For a full list of configuration options refer to https://github.com/linkedin/cruise-control/wiki/Configurations. Note that properties with the following prefixes cannot be set: bootstrap.servers, client.id, zookeeper., network., security., failed.brokers.zk.path,webserver.http., webserver.api.urlprefix, webserver.session.path, webserver.accesslog., two.step., request.reason.required,metric.reporter.sampler.bootstrap.servers, capacity.config.file, self.healing., ssl., kafka.broker.failure.detection.enable, topic.config.provider.class (with the exception of: ssl.cipher.suites, ssl.protocol, ssl.enabled.protocols, webserver.http.cors.enabled, webserver.http.cors.origin, webserver.http.cors.exposeheaders, webserver.security.enable, webserver.ssl.enable)."
                    metricsConfig:
                      type: object
                      properties:
                        type:
                          type: string
                          enum:
                            - jmxPrometheusExporter
                          description: Metrics type. Only 'jmxPrometheusExporter' supported currently.
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
                          description: "ConfigMap entry where the Prometheus JMX Exporter configuration is stored. For details of the structure of this configuration, see the {JMXExporter}."
                      required:
                        - type
                        - valueFrom
                      description: Metrics configuration.
                  description: Configuration for Cruise Control deployment. Deploys a Cruise Control instance when specified.
                jmxTrans:
                  type: object
                  properties:
                    image:
                      type: string
                      description: The image to use for the JmxTrans.
                    outputDefinitions:
                      type: array
                      items:
                        type: object
                        properties:
                          outputType:
                            type: string
                            description: "Template for setting the format of the data that will be pushed.For more information see https://github.com/jmxtrans/jmxtrans/wiki/OutputWriters[JmxTrans OutputWriters]."
                          host:
                            type: string
                            description: The DNS/hostname of the remote host that the data is pushed to.
                          port:
                            type: integer
                            description: The port of the remote host that the data is pushed to.
                          flushDelayInSeconds:
                            type: integer
                            description: How many seconds the JmxTrans waits before pushing a new set of data out.
                          typeNames:
                            type: array
                            items:
                              type: string
                            description: "Template for filtering data to be included in response to a wildcard query. For more information see https://github.com/jmxtrans/jmxtrans/wiki/Queries[JmxTrans queries]."
                          name:
                            type: string
                            description: Template for setting the name of the output definition. This is used to identify where to send the results of queries should be sent.
                        required:
                          - outputType
                          - name
                      description: "Defines the output hosts that will be referenced later on. For more information on these properties see, xref:type-JmxTransOutputDefinitionTemplate-reference[`JmxTransOutputDefinitionTemplate` schema reference]."
                    logLevel:
                      type: string
                      description: "Sets the logging level of the JmxTrans deployment.For more information see, https://github.com/jmxtrans/jmxtrans-agent/wiki/Troubleshooting[JmxTrans Logging Level]."
                    kafkaQueries:
                      type: array
                      items:
                        type: object
                        properties:
                          targetMBean:
                            type: string
                            description: If using wildcards instead of a specific MBean then the data is gathered from multiple MBeans. Otherwise if specifying an MBean then data is gathered from that specified MBean.
                          attributes:
                            type: array
                            items:
                              type: string
                            description: Determine which attributes of the targeted MBean should be included.
                          outputs:
                            type: array
                            items:
                              type: string
                            description: "List of the names of output definitions specified in the spec.kafka.jmxTrans.outputDefinitions that have defined where JMX metrics are pushed to, and in which data format."
                        required:
                          - targetMBean
                          - attributes
                          - outputs
                      description: "Queries to send to the Kafka brokers to define what data should be read from each broker. For more information on these properties see, xref:type-JmxTransQueryTemplate-reference[`JmxTransQueryTemplate` schema reference]."
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
                          description: Template for JmxTrans `Deployment`.
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
                          description: Template for JmxTrans `Pods`.
                        container:
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
                          description: Template for JmxTrans container.
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
                          description: Template for the JmxTrans service account.
                      description: Template for JmxTrans resources.
                  required:
                    - outputDefinitions
                    - kafkaQueries
                  description: "As of Strimzi 0.35.0, JMXTrans is not supported anymore and this option is ignored."
                kafkaExporter:
                  type: object
                  properties:
                    image:
                      type: string
                      description: The docker image for the pods.
                    groupRegex:
                      type: string
                      description: Regular expression to specify which consumer groups to collect. Default value is `.*`.
                    topicRegex:
                      type: string
                      description: Regular expression to specify which topics to collect. Default value is `.*`.
                    groupExcludeRegex:
                      type: string
                      description: Regular expression to specify which consumer groups to exclude.
                    topicExcludeRegex:
                      type: string
                      description: Regular expression to specify which topics to exclude.
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
                    logging:
                      type: string
                      description: "Only log messages with the given severity or above. Valid levels: [`info`, `debug`, `trace`]. Default log level is `info`."
                    enableSaramaLogging:
                      type: boolean
                      description: "Enable Sarama logging, a Go client library used by the Kafka Exporter."
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
                          description: Template for Kafka Exporter `Deployment`.
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
                          description: Template for Kafka Exporter `Pods`.
                        service:
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
                          description: Template for Kafka Exporter `Service`.
                        container:
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
                          description: Template for the Kafka Exporter container.
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
                          description: Template for the Kafka Exporter service account.
                      description: Customization of deployment templates and pods.
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
                      description: Pod liveness check.
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
                      description: Pod readiness check.
                  description: "Configuration of the Kafka Exporter. Kafka Exporter can provide additional metrics, for example lag of consumer group at topic/partition."
                maintenanceTimeWindows:
                  type: array
                  items:
                    type: string
                  description: "A list of time windows for maintenance tasks (that is, certificates renewal). Each time window is defined by a cron expression."
              required:
                - kafka
                - zookeeper
              description: "The specification of the Kafka and ZooKeeper clusters, and Topic Operator."
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
                listeners:
                  type: array
                  items:
                    type: object
                    properties:
                      type:
                        type: string
                        description: "*The `type` property has been deprecated, and should now be configured using `name`.* The name of the listener."
                      name:
                        type: string
                        description: The name of the listener.
                      addresses:
                        type: array
                        items:
                          type: object
                          properties:
                            host:
                              type: string
                              description: The DNS name or IP address of the Kafka bootstrap service.
                            port:
                              type: integer
                              description: The port of the Kafka bootstrap service.
                        description: A list of the addresses for this listener.
                      bootstrapServers:
                        type: string
                        description: A comma-separated list of `host:port` pairs for connecting to the Kafka cluster using this listener.
                      certificates:
                        type: array
                        items:
                          type: string
                        description: A list of TLS certificates which can be used to verify the identity of the server when connecting to the given listener. Set only for `tls` and `external` listeners.
                  description: Addresses of the internal and external listeners.
                kafkaNodePools:
                  type: array
                  items:
                    type: object
                    properties:
                      name:
                        type: string
                        description: The name of the KafkaNodePool used by this Kafka resource.
                  description: List of the KafkaNodePools used by this Kafka cluster.
                clusterId:
                  type: string
                  description: Kafka cluster Id.
                operatorLastSuccessfulVersion:
                  type: string
                  description: The version of the Strimzi Cluster Operator which performed the last successful reconciliation.
                kafkaVersion:
                  type: string
                  description: The version of Kafka currently deployed in the cluster.
              description: "The status of the Kafka and ZooKeeper clusters, and Topic Operator."
YAML
)
}
