variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "subnet_private" {
  description = "subnet type private"
  type        = list(string)
}

variable "subnet_public" {
  description = "subnet type public"
  type        = list(string)
}