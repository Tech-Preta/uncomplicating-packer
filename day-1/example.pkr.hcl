source "amazon-ebs" "basic-example" {
  region        = "us-east-2"
  source_ami    = "ami-0e83be366243f524a"
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer_AWS {{timestamp}}"
}

build {
  sources = [
    "source.amazon-ebs.basic-example"
  ]
}

/*
    This HCL code defines a Packer configuration for creating an Amazon Machine Image (AMI) using the "amazon-ebs" builder.
    The builder creates an instance in the specified region, installs the necessary software, and then creates an AMI from the instance.
    The resulting AMI will have the specified source AMI, instance type, SSH username, and a name that includes a timestamp.
    The build section specifies the sources to build, in this case, the "amazon-ebs.basic-example" source.
*/
