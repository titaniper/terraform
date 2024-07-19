# 구성

# 프로메테우스 스택으로 구성한다.
- https://github.com/prometheus-operator/prometheus-operator
- https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
- https://leehosu.github.io/kube-prometheus-stack

```
kubectl create namespace monitoring


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm pull prometheus-community/kube-prometheus-stack
tar xvfz kube-prometheus-stack-61.3.2.tgz 
- x: 아카이브에서 파일을 추출합니다.
- v: 자세한 출력, 추출 진행 상황을 보여줍니다.
- f: 아카이브 파일의 이름을 지정합니다.
- z: gzip으로 압축된 아카이브를 처리합니다.

kubectl create namespace monitoring
helm install prometheus . -n monitoring -f values.yaml
helm upgrade prometheus . -n monitoring -f values.yaml
helm uninstall prometheus -n monitoring

# helm install kube-prom-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f values.yaml
# helm ls -n monitoring
# helm upgrade kube-prom-stack prometheus-community/kube-prometheus-stack --namespace monitoring -f values.yaml
# helm uninstall kube-prom-stack -n monitoring
```

서비스 확인
```
kubectl describe service kube-prom-stack-kube-prome-prometheus -n monitoring


```