terraform { required_version = ">= 1.6.0" }
variable "cluster_name" { type = string, default = "portfolio-eks" }
output "cluster_name" { value = var.cluster_name }
