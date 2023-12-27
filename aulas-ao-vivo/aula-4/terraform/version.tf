terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3" # Use o operador "~>" para buscar a versão mais recente a partir da 5.0
    }
  }
}
