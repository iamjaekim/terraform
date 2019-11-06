terraform {
  required_providers {
    aws = "= 2.34.0"
  }
  backend "s3" {
    bucket = "bucketname"
    key    = "keyname"
    region = "us-east-1"
  }
}