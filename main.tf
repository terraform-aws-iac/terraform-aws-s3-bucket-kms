resource "aws_kms_key" "bucket_kms_key" {
  description             = "KMS Key used to encrypt provisioned bucket"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "bucket_kms_alias" {
  name          = "alias/${var.bucket_name}"
  target_key_id = aws_kms_key.bucket_kms_key.key_id
}

resource "aws_s3_bucket" "standard_bucket" {
  bucket = var.bucket_name
  acl    = var.canned_acl
  tags   = local.tags
  versioning {
    enabled = var.versioning_status
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.bucket_kms_key.arn
      }
    }
  }

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix")
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.standard_bucket.id
  
  block_public_acls   = var.block_public_acls
  block_public_policy = var.block_public_policy
  ignore_public_acls  = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}