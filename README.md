# terraform-aws-s3-bucket
This Terraform module creates a standardized basic s3 bucket with dynamic functionality to support server access logging, versioning, static websites and server side encryption utilizing a unique kms key.

## Supported Resources
The follow resource are created:
- s3 bucket
- kms key
- kms key alias

# Motivation
Using a standard s3 configuration allows you to consistently create an s3 bucket that meets your defined compliance standards. We can ensure every bucket is secure and consistent accross the board. 

## Supported Features
- Encryption (KMS)
- Versioning of objects(optional)
- Access logging(optional)
- Static website hosting(optional)

## Technology
- terraform 0.12
- AWS s3

## Requirements
- terraform 0.12
- AWS credentials configured i.g. AWS IAM user credentials, Gitlab runner/Jenkins Build server with IAM role and appropraite permissions

# Usage
To use the module follow the code snippets below and referenced variables

## Simple Bucket With Versioning
*main.tf*
```hcl
module "sample-s3-bucket" {
  source            = "git::https://gitlab.com/devinitly/terraform/modules/terraform-aws-s3-bucket.git?ref="
  bucket_name       = var.bucket_name
  region            = var.region
  versioning_status = var.versioning_status
  environment       = var.environment
  tags              = var.tags
}
```
*terraform.tfvars*
```hcl
bucket_name       = "bucket-name"
region            = "my-region"
versioning_status = true
evironment        = "my-env"
tags              = { Key = "value", key = "value" }
```

## Access Logging
To utilize the access logging for your bucket you first must have the following:
*  Destination bucket created and configured
*  Destination bucket must also have the canned acl "log-delivery-write" applied

The snippets below show a configured sample logging bucket and sample bucket for sending logs. In addition the logging bucket will collect access logs for itself.
**Please note that this configuration is following best practice by using the logging bucket state outputs as a datasource to fullfill the origin bucket.**

*main.tf*
```hcl
module "sample_logging_s3_bucket" {
  source            = "git::https://gitlab.com/devinitly/terraform/modules/terraform-aws-s3-bucket.git?ref="
  bucket_name       = var.bucket_name
  region            = var.region
  versioning_status = var.versioning_status
  environment       = var.environment
  tags              = var.tags
}
```
*terraform.tfvars*
```hcl
bucket_name       = "logging-bucket-name"
region            = "my-region"
versioning_status = true
canned_acl        = "log-delivery-write"
evironment        = "my-env"
tags              = { Key = "value", key = "value" }
```
*main.tf*
```hcl
module "sample_s3_bucket" {
  source            = "git::https://gitlab.com/devinitly/terraform/modules/terraform-aws-s3-bucket.git?ref="
  bucket_name       = var.bucket_name
  region            = var.region
  versioning_status = var.versioning_status
  logging           = { target_bucket = "terraform_remote_state.sample_logging_s3_bucket.outputs.bucket_id", target_prefix = "log/" }
  environment       = var.environment
  tags              = var.tags
}
```
*terraform.tfvars*
```hcl
bucket_name       = "bucket-name"
region            = "my-region"
versioning_status = true
logging           = { target_bucket = "data.sample_logging_s3_bucket_bucket_name", target_prefix = "log/" }
evironment        = "my-env"
tags              = { Key = "value", key = "value" }
```

## Variables
| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | -------- |
| bucket_name | Desired name for s3 backend state bucket | string | null | yes |
| region | Desired region for bucket | string | null | yes |
| canned_acl | Desired canned ACL with prefered grants | string | private | yes |
| versioning_status | Desired status for object versioning | bool | false | no |
| attach\_bucket\_policy | Set if bucket should have bucket policy attached to it | bool | false | no |
| bucket\_name\_prefix | Create the bucket using a specified prefix for the name | string | null | no |
| logging | Access bucket logging configuration | map(string) | { } | no |
| website | Static web-site hosting and/or redirect configuration | map(string) | { } | no |
| environment | The defining evironement of the Account: DEV, TST, STG, PRD, ROOT | string | null | yes |
| tags | Desired tags for the bucket | map(string) | { } | no |
| block\_public\_acls | Desired setting to block public ACL's | bool | true | no |
| block\_public\_policy | Desired setting to block public policies | bool | true | no |
| ignore\_public\_acls | Desired setting to ignore public ACL's | bool | true | no |
| restrict\_public\_buckets | Desired setting to restrict public bucket policies for the bucket | bool | true | no |
## Outputs
| Name | Description |
| ---- | ----------- |
| bucket_id | The name of the bucket |
| bucket_arn | The Amazon Resource Name (ARN) of the bucket |
| bucket\_kms\_key\_arn | The Amazon Resource Name (ARN) of the bucket kms key |
| bucket\_kms\_key\_id | The global unique identifier of the bucket kms key |
| bucket\_kms\_key\_alias\_arn | The Amazon Resource Name (ARN) of the bucket kms key alias