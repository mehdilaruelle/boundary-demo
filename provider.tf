terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.50"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

locals {
  tags = {
    "Name"        = "${lower(var.app)}-${lower(var.env)}",
    "owner"       = lower(var.owner),
    "environment" = lower(var.env),
    "application" = lower(var.app),
  }
}
