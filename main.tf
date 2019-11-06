variable "aws_ec2_key_name" {
  type = "string"
  description = "enter your existing ec2 key name"
}
module "networkingResources" {
  source = "./networking"
}
module "private" {
  source = "./priv_tier"
  vpc = "${module.networkingResources.vpc}"
  cidr = "${module.networkingResources.cidr}"
  priv1subnet = "${module.networkingResources.priv1subnet}"
  priv2subnet = "${module.networkingResources.priv2subnet}"
  keyname = "${var.aws_ec2_key_name}"
}
module "public" {
  source = "./pub_tier"
  vpc = "${module.networkingResources.vpc}"
  cidr = "${module.networkingResources.cidr}"
  pub1subnet = "${module.networkingResources.pub1subnet}"
  pub2subnet = "${module.networkingResources.pub2subnet}"
  keyname = "${var.aws_ec2_key_name}"
}
module "database" {
  source = "./db_tier"
  cidr = "${module.networkingResources.cidr}"
  priv1subnet = "${module.networkingResources.priv1subnet}"
  priv2subnet = "${module.networkingResources.priv2subnet}"
}
