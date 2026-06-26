output "cloudtrail_bucket_name" {
  value = aws_s3_bucket_versioning.cloudtrail_logs
}

output "kms_key_arn" {
  value = aws_kms_key.cloudtrail.arn
}

output "cloudtrail_name" {
value = aws_cloudtrail.main.name
}