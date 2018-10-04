# Jenkins AWS Terraform Module

This repo contains a Module to deploy a Jenkins cluster on AWS using Terraform.

### Usage

```json
provider "aws" {
  profile = "admin"
  region  = "eu-west-1"
}

module "jenkins" {
  source = "git@github.com:domingobishop/terraform-aws-jenkins.git"

  vpc_id = ""
  subnet_id = ""
  environment = ""
  ssh_key_name = ""
  aws_key_pair_private_key_path = ""
}
```
