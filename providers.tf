terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.22.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.19.0"
    }
  }
}