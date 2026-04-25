terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # officiële AWS provider van HashiCorp
      version = "~> 5.0"        # versie 5 ondersteunt nieuwere Kubernetes AMIs
    }
  }
}

provider "aws" {
  region = "us-east-1" # regio waar de S3 bucket en DynamoDB tabel worden aangemaakt
}

data "aws_caller_identity" "current" {} # haalt het huidige AWS account-ID op voor gebruik in de bucket naam

resource "aws_s3_bucket" "tfstate" {
  bucket = "devsecops-tfstate-${data.aws_caller_identity.current.account_id}" # unieke bucket naam op basis van account-ID

  lifecycle {
    prevent_destroy = true # voorkomt per ongeluk verwijderen van de state bucket
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id # koppelt versioning aan de state bucket

  versioning_configuration {
    status = "Enabled" # bewaart alle versies van de state file zodat je terug kunt rollen
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id # koppelt encryptie aan de state bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # versleutelt de state file at-rest met AES-256
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id # koppelt publieke toegangsbeperking aan de state bucket

  block_public_acls       = true # blokkeert publieke ACLs op objecten in de bucket
  block_public_policy     = true # blokkeert bucket policies die publieke toegang toestaan
  ignore_public_acls      = true # negeert bestaande publieke ACLs
  restrict_public_buckets = true # beperkt de bucket tot alleen geauthenticeerde AWS accounts
}

output "bucket_name" {
  value = aws_s3_bucket.tfstate.bucket # toont de bucket naam na apply, gebruik dit in de backend config
}
