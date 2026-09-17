variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "service_name" {
  description = "Name of the App Runner service"
  type        = string
  default     = "nodejs-argo"
}

variable "image_identifier" {
  description = "ECR image URI (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/nodejs-argo:latest). Must be built and pushed first."
  type        = string
}

variable "port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units (1024 = 1 vCPU)"
  type        = string
  default     = "1024"
}

variable "memory" {
  description = "Memory in MB"
  type        = string
  default     = "2048"
}

# Application environment variables
variable "uuid" {
  description = "Node UUID"
  type        = string
  default     = "9afd1229-b893-40c1-84dd-51e7ce204913"
  sensitive   = true
}

variable "argo_domain" {
  description = "Argo fixed tunnel domain (leave empty for temporary tunnel)"
  type        = string
  default     = ""
}

variable "argo_auth" {
  description = "Argo fixed tunnel token or JSON (leave empty for temporary tunnel)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cfip" {
  description = "Preferred CF IP/domain"
  type        = string
  default     = "saas.sin.fan"
}

variable "cfport" {
  description = "Preferred CF port"
  type        = string
  default     = "443"
}

variable "name_prefix" {
  description = "Node name prefix"
  type        = string
  default     = "env0"
}

variable "sub_path" {
  description = "Subscription path"
  type        = string
  default     = "sub"
}

variable "nezha_server" {
  description = "Nezha server"
  type        = string
  default     = ""
}

variable "nezha_key" {
  description = "Nezha key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "chat_id" {
  description = "Telegram chat ID"
  type        = string
  default     = ""
}

variable "bot_token" {
  description = "Telegram bot token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "show_log" {
  description = "Show logs"
  type        = string
  default     = "true"
}
