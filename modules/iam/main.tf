# PASSWORD POLICY (NIS2 Art.21 - Access Control)
resource "aws_iam_account_password_policy" "strict" {
      minimum_password_length        = 14
      require_lowercase_characters   = true
      require_numbers                = true
      require_uppercase_characters   = true
      require_symbols                = true
      allow_users_to_change_password = true
      max_password_age               = 90
      password_reuse_prevention      = 12
      hard_expiry                    = false
    }

# DENY ALL WITHOUT MFA POLICY (NIS2 Art.21)
resource "aws_iam_policy" "require_mfa" {
      name        = "${var.project_name}-require-mfa"
      description = "NIS2 Art.21 - Deny all actions if MFA not enabled"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "AllowViewAccountInfo"
            Effect = "Allow"
            Action = [
              "iam:GetAccountPasswordPolicy",
              "iam:ListVirtualMFADevices"
            ]
            Resource = "*"
          },
          {
            Sid    = "AllowManageOwnMFA"
            Effect = "Allow"
            Action = [
              "iam:CreateVirtualMFADevice",
              "iam:EnableMFADevice",
              "iam:GetUser",
              "iam:ListMFADevices",
              "iam:ResyncMFADevice"
            ]
            Resource = [
              "arn:aws:iam::*:mfa/$${aws:username}",
              "arn:aws:iam::*:user/$${aws:username}"
            ]
          },
          {
            Sid    = "DenyAllExceptMFAManagementWithoutMFA"
            Effect = "Deny"
            NotAction = [
              "iam:CreateVirtualMFADevice",
              "iam:EnableMFADevice",
              "iam:GetUser",
              "iam:ListMFADevices",
              "iam:ResyncMFADevice",
              "sts:GetSessionToken"
            ]
            Resource  = "*"
            Condition = {
              BoolIfExists = {
                "aws:MultiFactorAuthPresent" = "false"
              }
            }
          }
        ]
      })
    }

# SECURITY AUDITORS GROUP (Read-Only)
resource "aws_iam_group" "security_auditors" {
      name = "${var.project_name}-security-auditors"
    }

    resource "aws_iam_group_policy_attachment" "auditors_readonly" {
      group      = aws_iam_group.security_auditors.name
      policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
    }

    resource "aws_iam_group_policy_attachment" "auditors_mfa" {
      group      = aws_iam_group.security_auditors.name
      policy_arn = aws_iam_policy.require_mfa.arn
    }

#CLOUD ADMINS GROUP

resource "aws_iam_group" "cloud_admins" {
name = "${var.project_name}-cloud-admins"
}

resource "aws_iam_group_policy_attachment" "admins_policy" {
group      = aws_iam_group.cloud_admins.name
policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admins_mfa" {
group      = aws_iam_group.cloud_admins.name
policy_arn = aws_iam_policy.require_mfa.arn
}
