variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {}

variable "ubuntu_ami" {
	default = "ami-45224425"
	description = "ubuntu 16.04 ami will use data source later"
}

variable "instance_master" {
	default = "t2.micro"
	description = "instance size for nomad master server"
}

variable "instance_client" {
	default = "t2.micro"
	description = "instance size for nomad client"
}

variable "key_pair" {
	default = "aws-alpha-test"
	description = "key pair for instances"
}

variable "consul_join_tag_key" {
  description = "The key of the tag to auto-jon on EC2."
  default     = "consul_join"
}

variable "consul_join_tag_value" {
  description = "The value of the tag to auto-join on EC2."
  default     = "nomad_consul_cluster"
}

variable "namespace" {}

variable "servers" {
  description = "The number of consul servers."
  default = "3"
}