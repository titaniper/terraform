provider "kubernetes" {
  config_path = "~/.kube/config" # 경로를 kubeconfig 파일의 위치로 설정
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" # 경로를 kubeconfig 파일의 위치로 설정
  }
}
