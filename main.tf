module "vpc" {
	source = "github.com/partsalliance/aws_vpc_module/"
	name = "beta"
	vpc_cidr = "172.20.0.0/24"
	region = "${var.aws_region}"
	public_subnet_cidr = "172.20.0.0/26"
	private_subnet_cidr = "172.20.0.64/26"
}