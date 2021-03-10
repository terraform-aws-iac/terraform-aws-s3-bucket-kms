output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.standard_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.standard_bucket.arn
}

output "bucket_kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.bucket_kms_key.arn
}

output "bucket_kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.bucket_kms_key.key_id
}

output "bucket_kms_key_alias_arn" {
  description = "The ARN of the bucket kms key alias"
  value       = aws_kms_alias.bucket_kms_alias.arn
}
