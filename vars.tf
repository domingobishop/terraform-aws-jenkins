variable "vpc_id" {
  description = "Desired VPC for the ec2 instance"
}

variable "subnet_id" {
  description = "Desired subnet/s for the ec2 instance"
}

variable "cidr_blocks" {
  description = "Desired cidr block/s for the security group"
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Enviroment type, eg Dev, Test or Live"
}

variable "ami_id" {
  description = "Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type"
  default = "ami-047bb4163c506cd98"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_key_name" {
  description = "Create a Key Pair via AWS console and add the Key Pair Name here"
}

variable "aws_key_pair_private_key_path" {
  description = "After creating a Key Pair, add the pem file to a desired loaction eg ~/.aws/mac-ssh.pem"
}

variable "user" {
  default = "ec2-user"
}
