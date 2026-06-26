resource "aws_kms_key" "cloudtrail" {
      description             = "NIS2 - KMS key for CloudTrail logs encryption"
      deletion_window_in_days = 30
      enable_key_rotation     = true

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "Enable IAM Root Permissions"
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = "kms:*"
            Resource = "*"
          },
          {
            Sid    = "Allow CloudTrail to encrypt logs"
            Effect = "Allow"
            Principal = {
              Service = "cloudtrail.amazonaws.com"
            }
            Action = [
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ]
            Resource = "*"
          }
        ]
      })

      tags = {
        Name    = "${var.project_name}-cloudtrail-key"
        NIS2    = "Art21-Encryption"
        Project = var.project_name
      }
    }

    resource "aws_kms_alias" "cloudtrail" {
      name          = "alias/${var.project_name}-cloudtrail"
      target_key_id = aws_kms_key.cloudtrail.key_id
    }

    # DATA SOURCE (account ID)
    data "aws_caller_identity" "current" {}

    # S3 BUCKET FOR CLOUDTRAIL LOGS (NIS2 Art.21)
    resource "aws_s3_bucket" "cloudtrail_logs" {
      bucket        = "${var.project_name}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
      force_destroy = true

      tags = {
        Name    = "${var.project_name}-cloudtrail-logs"
        NIS2    = "Art21-Logging"
        Project = var.project_name
      }
    }

    resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
      bucket = aws_s3_bucket.cloudtrail_logs.id
      versioning_configuration {
        status = "Enabled"
        # filter {}

      }
    }


    resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
      bucket = aws_s3_bucket.cloudtrail_logs.id
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = aws_kms_key.cloudtrail.arn
        }
      }
    }

    resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
      bucket                  = aws_s3_bucket.cloudtrail_logs.id
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }

    resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
      bucket = aws_s3_bucket.cloudtrail_logs.id
      rule {
        id     = "retain-logs-365-days"
        status = "Enabled"
        filter {}
        expiration {
          days = 365
        }
      }
    }

    resource "aws_s3_bucket_policy" "cloudtrail_logs" {
      bucket = aws_s3_bucket.cloudtrail_logs.id
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "AWSCloudTrailAclCheck"
            Effect = "Allow"
            Principal = {
              Service = "cloudtrail.amazonaws.com"
            }
            Action   = "s3:GetBucketAcl"
            Resource = aws_s3_bucket.cloudtrail_logs.arn
          },
          {
            Sid    = "AWSCloudTrailWrite"
            Effect = "Allow"
            Principal = {
              Service = "cloudtrail.amazonaws.com"
            }
            Action   = "s3:PutObject"
            Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
            Condition = {
              StringEquals = {
                "s3:x-amz-acl" = "bucket-owner-full-control"
              }
            }
          }
        ]
      })
    }

    # CLOUDTRAIL (NIS2 Art.21 - Audit Trail)
    resource "aws_cloudtrail" "main" {
      name                          = "${var.project_name}-trail"
      s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
      include_global_service_events = true
      is_multi_region_trail         = true
      enable_log_file_validation    = true
      kms_key_id                    = aws_kms_key.cloudtrail.arn

      tags = {
        Name    = "${var.project_name}-trail"
        NIS2    = "Art21-AuditTrail"
        Project = var.project_name
      }
    }
