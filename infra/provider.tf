terraform {
  required_providers {
    aws = {
      version =">=4.9.0"
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  profile ="portfolio-profile"
  # OR
  # access_key = ${{ secrets.AWS_ACCESS_KEY_ID }}
  # secret_key = ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  region = "us-east-1"
}