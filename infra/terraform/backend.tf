terraform {
  backend "s3" {
    bucket       = "gymbro-terraform-state-620759833456"
    key          = "production/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
