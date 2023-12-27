/*
     Este código Terraform define um recurso de instância AWS EC2 e recupera o Ubuntu AMI mais recente criada pelo Packer.
     A instância do EC2 é iniciada com o tipo de instância e nome de host especificados.
     O script de dados do usuário define o nome do host da instância usando a variável fornecida.

     Este código usa a fonte de dados `aws_ami` para recuperar a AMI mais recente do Ubuntu com base nos filtros especificados.
     O recurso `aws_instance` é então criado com a AMI recuperada, o tipo de instância e o nome do host.
     O script `user_data` é usado para definir o nome do host da instância usando a variável fornecida.

     Observação: certifique-se de substituir o valor `proprietários` pelo ID da sua própria conta da AWS.
     Ponto de atenção: o recurso `aws_instance` usa o bloco `lifecycle` para ignorar alterações na AMI. 
     Isso é necessário porque a AMI é definida como uma fonte de dados e, portanto, não é gerenciada pelo Terraform.
     Caso não fosse utilizado o bloco `lifecycle`, o Terraform destruiria e recriaria a instância sempre que a AMI fosse alterada.
     Quando criamos uma instância EC2 na AWS, não conseguimos alterar sua AMI sem destruir e recriar a instância.

*/

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "tag:Release"
    values = ["1.*"]
  }

  filter {
    name   = "tag:OS_VERSION"
    values = ["ubuntu"]
  }

  owners = ["037562217043"] // ID da sua conta AWS
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name      = var.hostname
    Workspace = var.workspace
  }
  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname ${var.hostname}
EOF
}
