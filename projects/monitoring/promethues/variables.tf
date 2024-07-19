variable "discord_url" {
  description = "Discord webhook URL for Alertmanager"
  type        = string
  sensitive   = true
}

variable "env" {
  description = "env"
  type        = string
}