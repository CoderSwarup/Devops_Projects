terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }

  backend "s3" {
    bucket = "terra-495599770827-demo-bucket"
    key    = "backend.tfstate"
    region = "ap-south-1"
  }
}
