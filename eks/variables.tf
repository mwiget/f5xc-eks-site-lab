variable "aws_region" {
  type        = string
  description = "AWS region name"
}

variable "cluster_name" {
  type        = string
  default     = "example-eks1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key used to create infrastructure"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key used to create AWS infrastructure"
} 

variable "owner" {}

variable "kubernetes_version" {
  type    = string
  default = "1.23"
}

variable "worker_node_count" {
  type    = number
  default = 3
}

variable "kubeconfig_file" {
  type = string
  default = "./kubeconfig"
}
