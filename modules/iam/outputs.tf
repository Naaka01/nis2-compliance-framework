output "require_mfa_policy_arn" {
  description = "Name of the MFA enforcement policy."
  value       = aws_iam_policy.require_mfa.arn
}

output "security_auditors_group" {
  description = "Name of the security auditors IAM group."
  value       = aws_iam_group.security_auditors.arn
}

output "cloud_admins_group" {
  description = "Name of the cloud admins IAM group."
  value       = aws_iam_group.cloud_admins.arn
}

