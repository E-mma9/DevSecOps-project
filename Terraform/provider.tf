provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "devsecops-tfstate-450050505346" # naam van de S3 bucket die je hebt aangemaakt via bootstrap
    key            = "devsecops/terraform.tfstate"          # pad binnen de bucket waar de state file wordt opgeslagen
    region         = "us-east-1"                            # zelfde regio als de bucket
    use_lockfile   = true                                    # gebruikt S3 native locking via een .tflock bestand, vervangt DynamoDB locking
    encrypt        = true                                    # versleutelt de state file in transit
  }
}