variable "instance_type" {
  description = "O tipo de instância a ser usada"
  type        = string
  default     = "t2.micro"
}

variable "hostname" {
  description = "O nome do host"
  type        = string
  default     = "ubuntu"
}
variable "workspace" {
  description = "O nome do Workspace"
  type        = string
  default     = "example-1"
}
