

1. strimzi 세팅하기 위해 헬름 차트
https://github.com/strimzi/strimzi-kafka-operator/tree/main/helm-charts/helm3/strimzi-kafka-operator2. 
   

2. ??
```
kubectl exec -it kafka-ui-5f6d4955c7-xg5pr -n streaming -- nslookup kafka-kafka-bootstrap


kubectl exec -it kafka-ui-5f6d4955c7-xg5pr -n streaming -- /bin/sh

```

3. 브로커에서 디버깅
```
# Kafka 패키지 디렉토리로 이동
cd /opt/kafka/bin

# Kafka 토픽 목록을 출력
./kafka-topics.sh --list --bootstrap-server kafka-kafka-bootstrap:9092

```
