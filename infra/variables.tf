variable "db_username" {
  description = "Database username"
  default     = "default_username"
}

variable "db_password" {
  description = "Database password"
  default     = "default_password"
}

variable "email" {
  description = "Email address to send notifications to"
  default     = "default_email"
}

variable "create_IP" {
  description = "Whether to create an Elastic IP"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "SSH public key to SSH into bastion"
  default     = "default_public_key"
}

variable "region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}