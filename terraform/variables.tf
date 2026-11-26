variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "infra-deploy"
}

variable "dev" {
  type = object({
    env            = string
    vpc_cidr       = string
    subnet_private = list(string)
    subnet_public  = list(string)
  })
}


variable "prod" {
  type = object({
    env            = string
    vpc_cidr       = string
    subnet_private = list(string)
    subnet_public  = list(string)
  })
}


