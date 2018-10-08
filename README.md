# Jenkins AWS Terraform Module

Jenkins is a distributed automation server, generally associated with Continuous Integration (CI) and Continuous Delivery (CD). This Jenkins Terraform Module deploys a Jenkins cluster on AWS. This module creates the architecture (ec2 instance, security group and Elastic IP) and installs Jenkins and associated plugins. Please feel free to review the plugins to remove and add as you please. The two plugins necessary for AWS are CodeDeploy and EC2.

### Usage

```terraform
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
