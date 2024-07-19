# 1. 모듈에서 elastic operator 설치

# 2. 배포
<https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-kibana.html>


```
kubectl get storageclass

kubectl logs -f deployment/elastic-operator -n monitoring


kubectl delete pod elasticsearch-es-master-0 --grace-period=0 --force -n=monitoring
```


# MountVolume.SetUp failed for volume "elasticsearch-metricbeat-config" : failed to sync secret cache: timed out waiting for the condition


# 
비밀번호 확인
```
kubectl get secret elasticsearch-es-elastic-user -n monitoring -o=jsonpath='{.data.elastic}' | base64 --decode; echo

# 어차피 테스트 클러스터지롱~
elastic/hk85tdH35c4BmQYq0s934L0E
```