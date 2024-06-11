provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "upload-bucket"
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_sqs_queue" "queue" {
  name                      = "upload-queue"
  delay_seconds             = 60
  max_message_size          = 8192
  message_retention_seconds = 172800
  receive_wait_time_seconds = 15
}

resource "aws_sqs_queue_policy" "notify_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.iam_notify-policy-doc.json
}

resource "aws_s3_bucket_notification" "bucket_notify" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".txt"
  }
}

