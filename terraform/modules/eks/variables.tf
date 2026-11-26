variable "env" {
  description = "Environment name"
  type        = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "api_access_cidrs" {
  type = list(string)
}

variable "instance_types" {
  description = "EC2 instance types"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
}

variable "secret_names" {
  description = "Secrets managed by this environment"
  type        = set(string)
}