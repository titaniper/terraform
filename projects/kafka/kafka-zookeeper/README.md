
# 1. Kafka k8s위치

- <https://github.com/strimzi/strimzi-kafka-operator/blob/f23eb09baa86ac79a3728b8922f35a240fdb77ef/examples/metrics/kafka-metrics.yaml#L69>

# 2. Helm 경험

- <https://helm.sh/docs/intro/using_helm/>

```
helm repo add strimzi https://strimzi.io/charts
helm repo update
helm search repo strimzi
helm install strimzi-kafka-operator strimzi/strimzi-kafka-operator --namespace streaming
helm uninstall strimzi-kafka-operator -n default
helm uninstall strimzi-kafka-operator -n streaming
```

-> 헬름 릴리즈를 코드로 선언, 헬름 릴리즈도 제거하고 헬름 차트를 직접 가져와서 IaC 를 달성하는 것이 좋을 거 같음.

# 3. UI 구성

<https://www.notion.so/benkang/e53e373eb478430a9bc18b224b5a143e>

브로커 연결할 수 있는 거 확인

```
kubectl get svc -n streaming 
kubectl exec -it kafka-ui-58f99fc4c6-ccr7n -n streaming -- /bin/sh
nslookup streaming-kafka-bootstrap.streaming

kubectl get pods -n streaming
kubectl get svc -n streaming
```

```
minikube service kafka-ui-node-port -n streaming
```

<!-- minikube start --memory=4096 --driver=virtualbox -->
```
minikube delete
-- https://minikube.sigs.k8s.io/docs/drivers/qemu/#networking
brew install qemu

git clone https://github.com/lima-vm/socket_vmnet.git && cd socket_vmnet
sudo make install

minikube start --driver qemu --network socket_vmnet
minikube addons enable ingress

minikube stop
minikube delete
minikube start --vm=true

terraform apply
minikube addons enable ingress
```

- <https://kubernetes.io/ko/docs/tasks/access-application-cluster/ingress-minikube/>
- 인그레스 설정, host 수정 <https://kubernetes.io/ko/docs/tasks/access-application-cluster/ingress-minikube/>

````
<!-- kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml -->
<!-- kubectl proxy -->

-- 아래에서 나온 ip 를 인그레스 호스트로 지정
minikube tunnel
minikube addons enable ingress
minikube ip


minikube service list
minikube service kafka-ui-node-port -n streaming
minikube service kafka-ui-node-port -n streaming --url 

kubectl get po -n kube-system

kubectl logs kube-proxy-twpns -n kube-system
kubectl describe pod kube-proxy-twpns -n kube-system
kubectl get svc -n nginx
kubectl port-forward service/nginx-service 8080:80 -n nginx
kubectl port-forward service/kafka-ui-node-port2 31101:8080 -n streaming

```


# 디버깅
```
kubectl describe kafka kafka -n streaming
```