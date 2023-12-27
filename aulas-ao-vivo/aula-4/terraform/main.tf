provider "aws" {
  region = "us-east-1"

}
terraform {
  backend "s3" {
    bucket = "descomplicando-terraform-granato-tfstates" # Nome do bucket S3 onde o estado será armazenado
    key    = "terraform.tfstate"                         # Nome do arquivo de estado no bucket
    region = "us-east-2"                                 # Região da AWS onde o bucket está localizado                               
  }
}
