locals {
  release   = "1.0.0"
  ami_owner = "099720109477" // Canonical
  ami_name  = replace(replace(replace(local.release, "/", "-"), ".", "-"), "=", "-")
}

source "amazon-ebs" "ubuntu" {
  ami_name = local.ami_name

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = [local.ami_owner]
    most_recent = true
  }
  instance_type = "t2.micro"
  region        = "us-east-1"
  ssh_username  = "ubuntu"
  tags = {
    OS_VERSION = "ubuntu"
    Release    = local.release
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "echo provisioning all the things",
      "echo 'foo' > /tmp/teste"
    ]
  }
}
