terraform {
  backend "s3" {
    bucket = "blv-node-aws-jenkins-terraform"
    key = "bnode-aws-jenkins-terraform.tfstate"
    region = "us-east-2"
  }
}