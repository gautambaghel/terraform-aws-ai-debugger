data "aws_region" "current_region" {}
data "aws_region" "cloudfront_region" {
  # CloudFront must use us-east-1
  provider = aws.cloudfront_waf
}
data "aws_caller_identity" "current_account" {}
data "aws_partition" "current_partition" {}

#####################################################################################
# Managed IAM policies
#####################################################################################

data "aws_iam_policy" "lambda_basic_execution_managed_policy" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "bedrock_full_access_managed_policy" {
  name = "AmazonBedrockFullAccess"
}

data "aws_iam_policy" "ec2_readonly_managed_policy" {
  name = "AmazonEC2ReadOnlyAccess"
}

#####################################################################################
# LAMBDA ARCHIVE
#####################################################################################

data "archive_file" "ai_debugger_eventbridge" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/eventbridge/site-packages/"
  output_path = "${path.module}/lambda/eventbridge.zip"
  depends_on  = [terraform_data.bootstrap]
}

data "archive_file" "ai_debugger_request" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/request/site-packages/"
  output_path = "${path.module}/lambda/request.zip"
  depends_on  = [terraform_data.bootstrap]
}

data "archive_file" "ai_debugger_callback" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/callback/site-packages"
  output_path = "${path.module}/lambda/callback.zip"
  depends_on  = [terraform_data.bootstrap]
}

data "archive_file" "ai_debugger_fulfillment" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/fulfillment/site-packages"
  output_path = "${path.module}/lambda/fulfillment.zip"
  depends_on  = [terraform_data.bootstrap]
}

data "archive_file" "ai_debugger_edge" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/edge/site-packages"
  output_path = "${path.module}/lambda/edge.zip"
  depends_on  = [terraform_data.bootstrap]
}

#####################################################################################
# KMS
#####################################################################################
data "aws_iam_policy_document" "ai_debugger_key" {
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current_partition.id}:iam::${data.aws_caller_identity.current_account.account_id}:root"
      ]
    }
  }
  statement {
    sid    = "Allow Service CloudWatchLogGroup"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Describe",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current_region.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/lambda/${local.solution_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/state/${local.solution_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:/aws/vendedlogs/states/${local.solution_prefix}*",
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:${var.cloudwatch_log_group_name}*"
      ]
    }
  }
  statement {
    sid    = "Allow Service Secrets Manager"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:Describe"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.ai_debugger_eventbridge.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "secretsmanager.${data.aws_region.current_region.name}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values = [
        data.aws_caller_identity.current_account.account_id
      ]
    }
  }
}

data "aws_iam_policy_document" "ai_debugger_waf" {
  #checkov:skip=CKV_AWS_109:KMS management permission by IAM user
  #checkov:skip=CKV_AWS_111:wildcard permission required for kms key
  #checkov:skip=CKV_AWS_356:wildcard permission required for kms key
  count    = local.waf_deployment
  provider = aws.cloudfront_waf
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current_partition.id}:iam::${data.aws_caller_identity.current_account.account_id}:root"
      ]
    }
  }
  statement {
    sid    = "Allow Service CloudWatchLogGroup"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:Describe",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.cloudfront_region.name}.amazonaws.com"
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:${data.aws_partition.current_partition.id}:logs:${data.aws_region.cloudfront_region.name}:${data.aws_caller_identity.current_account.account_id}:log-group:aws-waf-logs-${local.solution_prefix}-ai_debugger_waf_acl*"
      ]
    }
  }
}

#####################################################################################
# WAF
#####################################################################################

data "aws_iam_policy_document" "ai_debugger_waf_log" {
  count   = local.waf_deployment
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.ai_debugger_waf[count.index].arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current_account.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}
