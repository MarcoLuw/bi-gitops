# Declaration of variables for Terraform EC2 provisioning
# Get values from "terraform.tfvars" file

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the existing SSH key in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}
