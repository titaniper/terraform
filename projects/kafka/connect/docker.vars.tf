variable "docker_username" {
  description = "Docker Hub Username"
  type        = string
}

variable "docker_password" {
  description = "Docker Hub Password"
  type        = string
  sensitive   = true
}

variable "docker_email" {
  description = "Docker Hub email"
  type        = string
}