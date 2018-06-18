data "aws_iam_policy_document" "node" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  assume_role_policy = "${data.aws_iam_policy_document.node.json}"
  name_prefix        = "${module.label.id}-instance-role"
}

resource "aws_iam_role_policy_attachment" "instance_role" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "instance_profile" {
  role        = "${aws_iam_role.ec2.name}"
  name_prefix = "${module.label.id}-instance-profile"
}

# Allow Spot request to run and terminate EC2 instances
data "aws_iam_policy_document" "spotfleet" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["spotfleet.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "taggingrole" {
  assume_role_policy = "${data.aws_iam_policy_document.spotfleet.json}"
  name_prefix        = "${module.label.id}-tagging-role"
}

resource "aws_iam_role_policy_attachment" "spot_request_policy" {
  role       = "${aws_iam_role.taggingrole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}
