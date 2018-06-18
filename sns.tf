data "aws_caller_identity" "default" {}

locals {
  sns_topic_arn = "${var.sns_topic_arn == "" ? aws_sns_topic.default.0.arn : var.sns_topic_arn }"
}

# Make a topic
resource "aws_sns_topic" "default" {
  name_prefix = "${module.label.id}"
}

resource "aws_sns_topic_policy" "default" {
  count  = "${var.add_sns_policy != "true" && var.sns_topic_arn != "" ? 0 : 1}"
  arn    = "${local.sns_topic_arn}"
  policy = "${data.aws_iam_policy_document.sns_topic_policy.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "sns_topic_policy"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect    = "Allow"
    resources = ["${local.sns_topic_arn}"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "arn:aws:iam::${data.aws_caller_identity.default.account_id}:root",
      ]
    }
  }

  statement {
    sid       = "Allow ${module.label.id} spot fleet CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = ["${local.sns_topic_arn}"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
