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
  cluster_name             = "${var.existing_cluster_name == "" ? aws_ecs_cluster.default.name : var.existing_cluster_name }"
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

resource "null_resource" "launch_specification" {
  count = "${length(var.instance_type_list) * length(var.subnet_ids)}"

  triggers {
    instance_type               = "${element(var.instance_type_list, count.index % length(var.instance_type_list))}"
    ami                         = "${local.ami_id}"
    iam_instance_profile_arn    = "${local.iam_instance_profile_arn}"
    key_name                    = "${var.ssh_key}"
    subnet_id                   = "${element(var.subnet_ids, count.index % length(var.subnet_ids))}"
    vpc_security_group_ids      = ["${local.security_groups}"]
    associate_public_ip_address = "${var.public_ip}"
    monitoring                  = "${var.monitoring}"
    ebs_optimized               = "${var.ebs_optimized}"
    placement_group             = "${var.placement_group}"
    user_data                   = "${data.template_cloudinit_config.config.rendered}"
    tags                        = "${module.label.tags}"
    root_block_device           = "${local.root_block_device}"
    ebs_block_device            = "${local.ebs_block_device}"
  }
}

resource "aws_spot_fleet_request" "default" {
  depends_on                          = ["aws_ecs_cluster.default"]
  iam_fleet_role                      = "${aws_iam_role.taggingrole.arn}"
  allocation_strategy                 = "${var.allocation_strategy}"
  target_capacity                     = "${var.target_capacity}"
  valid_until                         = "${var.valid_until}"
  wait_for_fulfillment                = "${var.wait_for_fulfillment}"
  excess_capacity_termination_policy  = "${var.excess_capacity_termination_policy}"
  terminate_instances_with_expiration = "${var.terminate_instances_with_expiration}"
  instance_interruption_behavior      = "${var.instance_interruption_behavior}"
  launch_specification                = ["${null_resource.launch_specification.triggers}"]
  valid_until                         = "${var.valid_until}"

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

  timeouts {
    create = "20m"
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
