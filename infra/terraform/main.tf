terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = ">= 5.95.0"
  }

}

provider "aws" {
  region = "us-east-1"
}