data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_ecs_cluster" "default" {
  count = "${var.existing_cluster_name == "" ? 1 : 0 }"
  name  = "${var.cluster_label == "" ? module.label.id : var.cluster_label}"
}

locals {
  cluster_name             = "${var.existing_cluster_name == "" ? join("",aws_ecs_cluster.default.*.name) : var.existing_cluster_name }"
  iam_instance_profile_arn = "${var.iam_instance_profile_arn == "" ? aws_iam_instance_profile.instance_profile.arn : ""}"
  ami_id                   = "${var.ami_id == "" ? data.aws_ami.ecs_ami.id : var.ami_id}"
  security_groups          = "${concat(var.security_group_ids, list(aws_security_group.default.id))}"

  ebs_block_device = [{
    device_name = "/dev/xvdcz"

    // Disk naming is important!
    volume_size = "${var.disk_size_docker}"
    volume_type = "gp2"
  }]

  root_block_device = [{
    volume_size = "${var.disk_size_root}"
    volume_type = "gp2"
  }]
}

data "aws_region" "default" {}

resource "aws_cloudwatch_log_group" "default" {
  name_prefix = "${module.label.id}"
  tags        = "${module.label.tags}"
}

# For each subnet_id and instance_type_list item, create a new launch spec block

# resource "null_resource" "launch_specification" {
#   count = "${length(var.instance_type_list) * length(var.subnet_ids)}"

#   triggers {
#     instance_type               = "${element(var.instance_type_list, count.index % length(var.instance_type_list))}"
#     ami                         = "${local.ami_id}"
#    iam_instance_profile_arn    = "${local.iam_instance_profile_arn}"
#    key_name                    = "${var.key_name}"
#     subnet_id                   = "${element(var.subnet_ids, count.index % length(var.subnet_ids))}"

#     associate_public_ip_address = "${var.associate_public_ip_address}"
#     monitoring                  = "${var.monitoring}"
#     ebs_optimized               = "${var.ebs_optimized}"
#    placement_group             = "${var.placement_group}"
#     user_data                  = "${data.template_cloudinit_config.config.rendered}"
#     instance_interruption_behavior      = "${var.instance_interruption_behavior}"
#     # These variables below won't work in a null_resource
#     # Must wait until the launch_template option is available

#     # tags                        = "${module.label.tags}"
#     # root_block_device           = "${local.root_block_device}"
#     # ebs_block_device            = "${local.ebs_block_device}"
#     # vpc_security_group_ids      = "${local.security_groups}"
#   }
# }

# output "launch_specification" {
#   value = ["${null_resource.launch_specification.*.triggers}"]
# }
output "user_data" {
  value = "${data.template_cloudinit_config.config.rendered}"
}

resource "aws_spot_fleet_request" "default" {
  depends_on                          = ["aws_ecs_cluster.default", "null_resource.launch_specification"]
  iam_fleet_role                      = "${aws_iam_role.taggingrole.arn}"
  allocation_strategy                 = "${var.allocation_strategy}"
  target_capacity                     = "${var.target_capacity}"
  wait_for_fulfillment                = "${var.wait_for_fulfillment}"
  excess_capacity_termination_policy  = "${var.excess_capacity_termination_policy}"
  terminate_instances_with_expiration = "${var.terminate_instances_with_expiration}"

  launch_specification = [
    {
      instance_type            = "${var.instance_type_list[0]}"
      ami                      = "${local.ami_id}"
      iam_instance_profile_arn = "${local.iam_instance_profile_arn}"
      key_name                 = "${var.key_name}"

      subnet_id                   = "${var.subnet_ids[0]}"
      vpc_security_group_ids      = ["${local.security_groups}"]
      associate_public_ip_address = "${var.associate_public_ip_address}"
      monitoring                  = "true"
      ebs_optimized               = "${var.ebs_optimized}"
      placement_group             = "${var.placement_group}"

      // root partition
      root_block_device {
        volume_size = "${var.disk_size_root}"
        volume_type = "gp2"
      }

      // docker partition
      ebs_block_device {
        device_name = "/dev/xvdcz"

        // Disk naming is important!
        volume_size = "${var.disk_size_docker}"
        volume_type = "gp2"
      }

      user_data = "${data.template_cloudinit_config.config.rendered}"
      tags      = "${module.label.tags}"
    },
  ]

  timeouts {
    create = "20m"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "default" {
  name_prefix = "${module.label.id}"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${var.outbound_traffic_cidr}"]
  description = "${module.label.id}"

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "ssh_access" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.cidr_range_for_ssh_access}"]
  description = "${module.label.id}"

  security_group_id = "${aws_security_group.default.id}"
}

# launch_specification {
#   instance_type            = "${var.ec2_type}"
#   ami                      = "${local.ami_id}"
#   iam_instance_profile_arn = "${local.iam_instance_profile_arn}"
#   key_name                 = "${var.ssh_key}"


#   # subnet_id                   = "${var.subnet_id}"
#   vpc_security_group_ids      = ["${local.security_groups}"]
#   associate_public_ip_address = "${var.public_ip}"
#   monitoring                  = "true"
#   ebs_optimized               = "${var.ebs_optimized}"
#   placement_group             = "${var.placement_group}"


#   // root partition
#   root_block_device {
#     volume_size = "${var.disk_size_root}"
#     volume_type = "gp2"
#   }


#   // docker partition
#   ebs_block_device {
#     device_name = "/dev/xvdcz"


#     // Disk naming is important!
#     volume_size = "${var.disk_size_docker}"
#     volume_type = "gp2"
#   }


#   user_data = "${data.template_cloudinit_config.config.rendered}"
#   tags      = "${module.label.tags}"
# }

