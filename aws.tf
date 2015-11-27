provider "aws" {
  region = "${var.aws_region}"
}

module "aws-dc" {
  source = "./terraform/aws"
  availability_zone = "${var.az}"
  ssh_username = "centos"
  source_ami = "ami-61bbf104"

  control_count = "${var.control_count}"
  worker_count = "${var.worker_count}"
  edge_count = "${var.edge_count}"
}



module "dns" {
  source = "./terraform/route53/dns"

  control_count = "${var.control_count}"
  control_ips = "${module.aws-dc.control_ips}"
  domain = "${var.domain}"
  edge_count = "${var.edge_count}"
  edge_ips = "${module.aws-dc.edge_ips}"
  short_name = "${var.short_name}"
  subdomain ="${var.sub_domain}"
  worker_count = "${var.worker_count}"
  worker_ips = "${module.aws-dc.worker_ips}"
  control_subdomain ="control"
  hosted_zone_id="${var.hosted_zone_id}"

}



# Example setup for an AWS ELB
module "aws-elb" {
  source = "./terraform/aws-elb"
  short_name = "${var.short_name}"
  instances = "${module.aws-dc.control_ids}"
  subnets = "${module.aws-dc.vpc_subnet}"
  security_groups = "${module.aws-dc.ui_security_group},${module.aws-dc.default_security_group}"

}



