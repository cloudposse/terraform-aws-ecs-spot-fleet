# Render a part using a `template_file`
data "template_file" "script" {
  template = "${file("${path.module}/user-data/init.sh")}"

  vars {
    region       = "${data.aws_region.default.name}"
    cluster_name = "${local.cluster_name}"
    logsgroup    = "${aws_cloudwatch_log_group.default.name}"
    snstopic     = "${local.sns_topic_arn}"
  }
}

# Render a multi-part cloudinit config making use of the part
# above, and other source files
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    order        = 1
    filename     = "init.sh"
    content_type = "text/part-handler"
    content      = "${data.template_file.script.rendered}"
  }

  part {
    order        = 2
    content_type = "text/x-shellscript"
    content      = "${var.additional_user_data}"
  }
}
