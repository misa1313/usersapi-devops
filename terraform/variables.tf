variable "key_name" {
  description = "SSH key name for the instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type."
  type        = string
}

variable "vpc_cidr_block" {
  type = string
  description = "The CIDR block for the VPC."
}

variable "subnet_cidr_block" {
  type = string
  description = "The CIDR block for the subnet."
}


