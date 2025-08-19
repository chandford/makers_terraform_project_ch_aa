
# Contains information about the provider to install (+which version of Terraform to use to provision your infrastructure)
# Contains information related to Terraform backend storage

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket = "c-h-terraform-state-bucket"
    key    = "tfstate"
    region = "eu-west-2"
  }

}