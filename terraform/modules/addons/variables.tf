variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "argocd_values" {
  type = string
}

variable "argocd_chart_version" {
  type = string
}

variable "vpc_id" {
  type = string
}