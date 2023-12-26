/*
  This Packer configuration file creates an Amazon Machine Image (AMI) for Zabbix on Ubuntu 22.04.
  It uses the Amazon Elastic Block Store (EBS) as the source and provisions the necessary software and configurations.
  The resulting AMI can be used to deploy Zabbix instances on AWS.

  Variables:
  - aws_access_key: The AWS access key used for authentication.
  - aws_secret_key: The AWS secret key used for authentication.

  Required Plugins:
  - amazon: The Amazon plugin is required to interact with AWS.

  Source:
  - amazon-ebs: The source block specifies the details of the Amazon Machine Image (AMI) to use as the base image.

  Build:
  - sources: The sources block specifies the source block to use for building the AMI.
  
  Provisioners:
  - file: The file provisioner copies files from the local machine to the remote machine during the build process.
    It copies the Docker Compose file and executes commands to install Docker and Docker Compose, and start the Zabbix containers.
*/

variable "aws_access_key" {}
variable "aws_secret_key" {}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  source_ami         = "ami-0e83be366243f524a"
  ami_name           = "Zabbix-Compose-Ubuntu-22.04 {{timestamp}}"
  instance_type      = "t2.medium"
  region             = "us-east-2"
  ssh_username       = "ubuntu"
  vpc_id             = "vpc-0e9166caa8d1c7803"
  security_group_ids = ["sg-0f6b721b535d7d269"]
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "./zabbix_compose/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo curl https://get.docker.com | bash",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo systemctl enable docker",
      "sudo systemctl restart docker",
      "sudo docker-compose up -d"
    ]
  }
}
