terraform {
  backend "s3" {
    bucket         = "eng4today-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eng4today-terraform-locks"
    encrypt        = true
  }
}
