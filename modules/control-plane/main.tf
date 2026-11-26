terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

variable "name" { type = string }
variable "environment" { type = string }
variable "subnet_ids" { type = set(string) }

locals {
  tags = { Project = "portfolio-eks", Environment = var.environment, ManagedBy = "terraform" }
}

resource "aws_iam_role" "cluster" {
  name = "${var.name}-control-plane"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "eks.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name                      = var.name
  version                   = "1.34"
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  tags       = local.tags
  depends_on = [aws_iam_role_policy_attachment.cluster]
}

output "name" { value = aws_eks_cluster.this.name }
output "private_endpoint" { value = aws_eks_cluster.this.vpc_config[0].endpoint_private_access }
output "public_endpoint" { value = aws_eks_cluster.this.vpc_config[0].endpoint_public_access }
