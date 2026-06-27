    # NIS2 Compliance Mapping — AWS Terraform Implementation

    | NIS2 Article | Requirement | AWS Service | Terraform Resource |
    |---|---|---|---|
    | Art. 21 §2(a) | Risk analysis and information security policies | AWS Config | aws_config_config_rule |
    | Art. 21 §2(b) | Incident handling | GuardDuty + SNS | aws_guardduty_detector + aws_sns_topic |
    | Art. 21 §2(c) | Business continuity | S3 Versioning + Lifecycle | aws_s3_bucket_versioning |
    | Art. 21 §2(d) | Supply chain security | IAM Least Privilege | aws_iam_policy |
    | Art. 21 §2(e) | Security in acquisition | Security Hub | aws_securityhub_account |
    | Art. 21 §2(f) | Effectiveness assessment | AWS Config Rules | aws_config_config_rule |
    | Art. 21 §2(g) | Cybersecurity training | IAM Groups + MFA | aws_iam_group |
    | Art. 21 §2(h) | Cryptography | KMS | aws_kms_key |
    | Art. 21 §2(i) | Human resources security | IAM Password Policy | aws_iam_account_password_policy |
    | Art. 21 §2(j) | Access control | MFA Enforcement Policy | aws_iam_policy (require_mfa) |
    | Art. 23 §1 | Incident notification within 24h | CloudWatch + SNS | aws_cloudwatch_metric_alarm |
    | Art. 23 §2 | Early warning within 24h | GuardDuty findings | aws_guardduty_detector |