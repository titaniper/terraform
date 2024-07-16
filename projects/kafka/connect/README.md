

````
kubectl get pvc -n streaming

kubectl get configmap -n streaming
```

# 커넥트
```
kubectl describe kafkaconnect kafka-connect -n streaming

```


# 커넥터 사앹
```


kubectl describe kafkaconnector debezium-mysql-connector2 -n streaming

kubectl get pods -n streaming -l app=kafka-connect

kubectl get kafkaconnector debezium-mysql-connector2 -n streaming -o yaml
```