variable "key_name" {
  description = "SSH key name for the instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type = string
}

variable "subnet_cidr_block" {
  description =  "The CIDR block for the subnet."
  type = string
}

variable "ssh_key_file" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"
}
