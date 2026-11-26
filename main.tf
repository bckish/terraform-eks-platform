terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Choose dev, qa, or prod."
  }
}

variable "subnet_ids" {
  type        = set(string)
  description = "Existing private subnets in at least two availability zones; verify topology before any real plan."
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two distinct subnets are required."
  }
}

module "cluster" {
  source      = "./modules/control-plane"
  name        = "portfolio-${var.environment}"
  environment = var.environment
  subnet_ids  = var.subnet_ids
}

output "cluster_name" {
  value = module.cluster.name
}

output "private_endpoint" {
  value = module.cluster.private_endpoint
}

output "public_endpoint" {
  value = module.cluster.public_endpoint
}
