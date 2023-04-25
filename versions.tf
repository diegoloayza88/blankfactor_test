terraform {
  required_version = "1.2.9"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "terraform-state-interview-27"
    key            = "state/interview_27"
    dynamodb_table = "tfstate_interview_27"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.75"
    }
  }
}