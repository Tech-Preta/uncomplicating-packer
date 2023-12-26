packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
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
  ami_name        = "packer_AWS ${local.timestamp}"
  instance_type   = "t2.micro"
  region          = "us-east-1"
  source_ami      = "${data.amazon-ami.granato.id}"
  ssh_username    = "ubuntu"
  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
    OS_Version    = "Ubuntu"
    Release       = "Latest"
  }
}

build {
  sources = ["source.amazon-ebs.granato"]
  provisioner "ansible" {
    use_proxy               = false
    playbook_file           = "./playbook.yml"
    ansible_env_vars        = ["PACKER_BUILD_NAME={{ build_name }}"]
    inventory_file_template = "{{ .HostAlias }} ansible_host={{ .ID }} ansible_user={{ .User }} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand=\"sh -c \\\"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p\\\"\"'\n"
  }
}