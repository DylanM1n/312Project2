variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "minecraft_key_name" {
  description = "Name of an existing EC2 KeyPair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
