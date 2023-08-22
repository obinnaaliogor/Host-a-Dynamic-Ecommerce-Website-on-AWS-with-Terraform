terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "wiz-terraform-state-file"
    key    = "dev-ecommerce/terraform.tfstate"

    region = "us-east-1"
  }


}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = var.profile
}
