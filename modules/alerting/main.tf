# SNS TOPIC (NIS2 Art.23 - Incident Notification)
   
    resource "aws_sns_topic" "security_alerts" {
      name = "${var.project_name}-security-alerts"
      tags = {
        NIS2    = "Art23-IncidentNotification"
        Project = var.project_name
      }
    }

    resource "aws_sns_topic_subscription" "email_alert" {
      topic_arn = aws_sns_topic.security_alerts.arn
      protocol  = "email"
      endpoint  = var.alert_email
    }

# CLOUDWATCH LOG GROUP
    resource "aws_cloudwatch_log_group" "cloudtrail" {
        name              = "/aws/cloudtrail/${var.project_name}"
        retention_in_days = 365
        }

# ALARME 1 : Connexion root détectée
resource "aws_cloudwatch_log_metric_filter" "root_login" {
      name           = "${var.project_name}-root-login"
      log_group_name = aws_cloudwatch_log_group.cloudtrail.name
      pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

      metric_transformation {
        name      = "RootLoginCount"
        namespace = "${var.project_name}/NIS2Compliance"
        value     = "1"
      }
    }

    resource "aws_cloudwatch_metric_alarm" "root_login" {
      alarm_name          = "${var.project_name}-root-login-detected"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      metric_name         = "RootLoginCount"
      namespace           = "${var.project_name}/NIS2Compliance"
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      alarm_description   = "NIS2 Art.21 - Root account login detected"
      alarm_actions       = [aws_sns_topic.security_alerts.arn]
      treat_missing_data  = "notBreaching"
    }

    
    # ALARME 2 : Suppression d'un trail CloudTrail
    #
    resource "aws_cloudwatch_log_metric_filter" "cloudtrail_deleted" {
      name           = "${var.project_name}-cloudtrail-deleted"
      log_group_name = aws_cloudwatch_log_group.cloudtrail.name
      pattern        = "{ ($.eventName = DeleteTrail) || ($.eventName = StopLogging) || ($.eventName = UpdateTrail) }"

      metric_transformation {
        name      = "CloudTrailChanges"
        namespace = "${var.project_name}/NIS2Compliance"
        value     = "1"
      }
    }

    resource "aws_cloudwatch_metric_alarm" "cloudtrail_deleted" {
      alarm_name          = "${var.project_name}-cloudtrail-tampered"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      metric_name         = "CloudTrailChanges"
      namespace           = "${var.project_name}/NIS2Compliance"
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      alarm_description   = "NIS2 Art.21 - CloudTrail tampered or deleted"
      alarm_actions       = [aws_sns_topic.security_alerts.arn]
      treat_missing_data  = "notBreaching"
    }

# ALARME 3 : Changement de policy IAM
 resource "aws_cloudwatch_log_metric_filter" "iam_policy_change" {
      name           = "${var.project_name}-iam-policy-change"
      log_group_name = aws_cloudwatch_log_group.cloudtrail.name
      pattern        = "{ ($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) }"

      metric_transformation {
        name      = "IAMPolicyChanges"
        namespace = "${var.project_name}/NIS2Compliance"
        value     = "1"
      }
    }

    resource "aws_cloudwatch_metric_alarm" "iam_policy_change" {
      alarm_name          = "${var.project_name}-iam-policy-changed"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      metric_name         = "IAMPolicyChanges"
      namespace           = "${var.project_name}/NIS2Compliance"
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      alarm_description   = "NIS2 Art.21 - IAM policy modified"
      alarm_actions       = [aws_sns_topic.security_alerts.arn]
      treat_missing_data  = "notBreaching"
    }

    # ALARME 4 : S3 bucket rendu public
    resource "aws_cloudwatch_log_metric_filter" "s3_public" {
      name           = "${var.project_name}-s3-public-access"
      log_group_name = aws_cloudwatch_log_group.cloudtrail.name
      pattern        = "{ ($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) }"

      metric_transformation {
        name      = "S3BucketChanges"
        namespace = "${var.project_name}/NIS2Compliance"
        value     = "1"
      }
    }

    resource "aws_cloudwatch_metric_alarm" "s3_public" {
      alarm_name          = "${var.project_name}-s3-bucket-policy-changed"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      metric_name         = "S3BucketChanges"
      namespace           = "${var.project_name}/NIS2Compliance"
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      alarm_description   = "NIS2 Art.21 - S3 bucket policy modified"
      alarm_actions       = [aws_sns_topic.security_alerts.arn]
      treat_missing_data  = "notBreaching"
    }

