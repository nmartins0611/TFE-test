################################################################################
# main.tf - Main Terraform Configuration
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    # ansible = {
    #   source  = "ansible/ansible"
    #   version = "~> 1.3.0"
    # }
  }
}

################################################################################
# Vault Provider Configuration
################################################################################

provider "vault" {
  # Address and token configured via environment variables:
  # VAULT_ADDR and VAULT_TOKEN in TFE workspace
}

################################################################################
# Data Sources - AWS Static Credentials from Vault
################################################################################

data "vault_kv_secret_v2" "aws_creds" {
  mount = var.vault_kv_mount
  name  = "aws/credentials"
}

################################################################################
# AWS Provider Configuration using Vault Static Credentials
################################################################################

provider "aws" {
  region     = var.aws_region
  access_key = data.vault_kv_secret_v2.aws_creds.data["access_key"]
  secret_key = data.vault_kv_secret_v2.aws_creds.data["secret_key"]
}

################################################################################
# Random Password Generation
################################################################################

resource "random_password" "instance_password" {
  length  = 24
  special = true
  lower   = true
  upper   = true
  numeric = true
}

################################################################################
# Store Password in Vault
################
