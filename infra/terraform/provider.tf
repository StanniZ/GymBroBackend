provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project     = "GymBro"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}
