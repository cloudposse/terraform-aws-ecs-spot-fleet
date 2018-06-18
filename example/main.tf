data "aws_region" "default" {}

data "aws_subnet" "default" {
  id = "${data.aws_subnet_ids.all.ids[0]}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

provider "aws" {
  region = "us-east-1"
}

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace             = "cp"
  stage                 = "prod"
  name                  = "app"
  ssh_public_key_path   = "."
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}


module "fleet" {
  source = "../"
  namespace  = "cp"
  stage      = "dev"
  name       = "app"
  key_name = "${module.ssh_key_pair.key_name}"
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = ["${data.aws_subnet_ids.all.ids}"]
}

# output "spot_request_state" {
#   value = "${module.fleet.spot_request_state}"
# }

# output "request_id" {
#   value = "${module.fleet.request_id}"
# }

output "cluster_name" {
  value = "${module.fleet.cluster_name}"
}

output "cluster_arn" {
  value = "${module.fleet.cluster_arn}"
}
output "launch_specification" {
  value = "${module.fleet.launch_specification}"
}
output "user_data" {
  value = "${module.fleet.user_data}"
}
