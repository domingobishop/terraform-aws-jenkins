# Jenkins Master Server Security Group
resource "aws_security_group" "jenkins_http_ssh_access" {
  name = "jenkins_http_ssh_access"
  description = "Jenkins security group HTTP and SSH access"
  vpc_id = "${var.vpc_id}"

  # Allow HTTP access
  ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  # Allow HTTPS access
  ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  # Allow SSH access
  ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "${var.cidr_blocks}"
  }

  tags {
    Name = "jenkins"
    Environment = "${var.environment}"
    Terraform = "True"
  }
}

# Master Server
resource "aws_instance" "ec2_jenkins_master" {
  count                  = 1
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.ssh_key_name}"
  vpc_security_group_ids = ["${aws_security_group.jenkins_http_ssh_access.id}"]
  subnet_id = "${var.subnet_id}"
  associate_public_ip_address = true

  provisioner "file" {
    source     = "jenkins_server.sh"
    destination = "/tmp/jenkins_server.sh"

    connection {
      user        = "${var.user}"
      private_key = "${file(var.aws_key_pair_private_key_path)}"
    }
  }

  provisioner "file" {
    source     = "jenkins_password.sh"
    destination = "/tmp/jenkins_password.sh"

    connection {
      user        = "${var.user}"
      private_key = "${file(var.aws_key_pair_private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/jenkins_server.sh",
      "chmod +x /tmp/jenkins_password.sh",
      "sudo bash /tmp/jenkins_server.sh",
      "sudo su -c 'SHOW_JENKINS_PASSWORD=1 bash /tmp/jenkins_password.sh'",
    ]
    
    connection {
      user        = "${var.user}"
      private_key = "${file(var.aws_key_pair_private_key_path)}"
    }
  }

  tags {
    Name = "jenkins_master_${var.environment}"
    Environment = "${var.environment}"
    Terraform = "True"
  }
}

# Master Server Elastic IP address
resource "aws_eip" "jenkins_master" {
  instance = "${aws_instance.ec2_jenkins_master.id}"
  vpc      = true
}