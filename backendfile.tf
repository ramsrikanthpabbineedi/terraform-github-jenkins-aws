terraform {
  backend "s3" {
    bucket = "ramram-bucket"
    key    = "ram/terraform.tf"
    region = "eu-north-1"

  }
}