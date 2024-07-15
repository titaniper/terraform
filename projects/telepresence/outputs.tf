output "namespace" {
  value = kubernetes_namespace.telepresence.metadata[0].name
}

output "telepresence_status" {
  value = helm_release.telepresence.status
}
