variable "aws_access_key" {
  sensitive = true
  default   = env("AWS_ACCESS_KEY_ID")
}

variable "aws_secret_key" {
  sensitive = true
  default   = env("AWS_SECRET_ACCESS_KEY")
}

variable "aws_region" {}
variable "instance_type" {}
variable "ssh_username" {}
variable "ami_name" {}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "granato" {
  filters = {
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "granato" {
  ami_description = "from {{ .SourceAMI }}"
  ami_name        = "${var.ami_name} ${local.timestamp}"
  instance_type   = var.instance_type
  region          = var.aws_region
  source_ami      = "${data.amazon-ami.granato.id}"
  ssh_username    = var.ssh_username
  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
    OS_Version    = "Ubuntu"
    Release       = "Latest"
  }
}

build {
  sources = ["source.amazon-ebs.granato"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "sudo curl https://get.docker.com | bash",
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",
      "sudo systemctl enable docker",
      "sudo systemctl restart docker"
    ]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p ~/minio/data",
      "docker run -d -p 9000:9000 -p 9090:9090 --name minio -v ~/minio/data:/data -e 'MINIO_ROOT_USER=ROOTNAME' -e 'MINIO_ROOT_PASSWORD=CHANGEME123' quay.io/minio/minio server /data --console-address ':9090'"
    ]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}