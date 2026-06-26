# GUARDUTY - THREAT DETECTION (NIS2 Art.21)

resource "aws_guardduty_detector" "main" {
      enable = true

      datasources {
        s3_logs {
          enable = true
        }
      kubernetes {
          audit_logs {
            enable = true
          }
        }
        malware_protection {
          scan_ec2_instance_with_findings {
            ebs_volumes {
              enable = true
            }
          }
        }
      }

      tags = {
        Name    = "${var.project_name}-guardduty"
        NIS2    = "Art21-ThreatDetection"
        Project = var.project_name
      }
    }


# SECURITY HUB - SECURITY POSTURE (NIS2 Art.21)
resource "aws_securityhub_account" "main" {}
resource "aws_securityhub_standards_subscription" "aws_foundational" {
      depends_on = [aws_securityhub_account.main]
      standards_arn = "arn:aws:securityhub:eu-west-1::standards/aws-foundational-security-best-practices/v/1.0.0"
    }

# AWS CONFIG CONTINUOUS-COMPLIANCE (NIS2 Art.21)
    resource "aws_config_configuration_recorder" "main" {
      name     = "${var.project_name}-recorder"
      role_arn = aws_iam_role.config_role.arn
      recording_group {
        all_supported = true
        include_global_resource_types = true
      }
    }

    resource "aws_iam_role" "config_role" {
      name = "${var.project_name}-config-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "config.amazonaws.com"
            }
          }
        ]
      })
    }

    resource "aws_iam_role_policy_attachment" "config_policy" {
      role       = aws_iam_role.config_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
    }

    resource "aws_config_configuration_recorder_status" "main" {
      name    = aws_config_configuration_recorder.main.name
      is_enabled = true
      depends_on = [aws_config_delivery_channel.main]
    }

    resource "aws_config_delivery_channel" "main" {
        name           = "${var.project_name}-config-delivery-channel"
        s3_bucket_name = var.config_bucket_name
        depends_on     = [aws_config_configuration_recorder.main]
    }

    #CONFIG RULE NIS2 

    resource "aws_config_config_rule" "root_mfa" {
      name = "${var.project_name}-root-mfa"
      source {
        owner             = "AWS"
        source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
      }
      tags = { NIS2 = "Art21-AccessControl" }
      }

    resource "aws_config_config_rule" "iam_user_mfa" {
      name = "${var.project_name}-iam-user-mfa-enabled"
      source {
        owner             = "AWS"
        source_identifier = "IAM_USER_MFA_ENABLED"
      }
      tags = { NIS2 = "Art21-AccessControl" }
    }

    resource "aws_config_config_rule" "cloudtrail_enabled" {
      name = "${var.project_name}-cloudtrail-enabled"
      source {
        owner             = "AWS"
        source_identifier = "CLOUD_TRAIL_ENABLED"
      }
      tags = { NIS2 = "Art21-AuditTrail" }
    }

    resource "aws_config_config_rule" "s3_no_public" {
      name = "${var.project_name}-s3_bucket-public-read-prohibited"
      source {
        owner             = "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
      }
      tags = { NIS2 = "Art21-DataProtection" }
    }

    resource "aws_config_config_rule" "s3_encryption" {
        name = "${var.project_name}-s3_bucket-server-side-encryption-enabled"
        source {
            owner             = "AWS"
            source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
        }
        tags = { NIS2 = "Art21-Encryption" }
    }

    resource "aws_config_config_rule" "guardduty_enabled" {
        name = "${var.project_name}-guardduty-enabled-centralized"
        source {
            owner             = "AWS"
            source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
        }
        tags = { NIS2 = "Art21-ThreatProtection" }
    }

    resource "aws_config_config_rule" "iam_password_policy" {
        name = "${var.project_name}-iam-password-policy"
        source {
            owner             = "AWS"
            source_identifier = "IAM_PASSWORD_POLICY"
        }
        tags = { NIS2 = "Art21-AccessControl" }
    }

    resource "aws_config_config_rule" "no_root_access_key" {
        name = "${var.project_name}-iam-root-access-key-check"
        source {
            owner             = "AWS"
            source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
        }
        tags = { NIS2 = "Art21-LeastPrivilege" }
    }

