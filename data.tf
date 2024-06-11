data "aws_iam_policy_document" "iam_notify-policy-doc" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:::upload-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:s3:::upload-bucket"]
    }
  }
}