#####################################################################################
# SECRETS MANAGER
#####################################################################################

resource "random_uuid" "ai_debugger_hmac" {}

resource "aws_secretsmanager_secret" "ai_debugger_hmac" {
  #checkov:skip=CKV2_AWS_57:run terraform apply to rotate hmac
  name                    = "${local.solution_prefix}-ai_debugger_hmac"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = aws_kms_key.ai_debugger_key.arn
  tags                    = local.combined_tags
}

resource "aws_secretsmanager_secret_version" "ai_debugger_hmac" {
  secret_id     = aws_secretsmanager_secret.ai_debugger_hmac.id
  secret_string = random_uuid.ai_debugger_hmac.result
}

resource "aws_secretsmanager_secret" "hcp_tf_api_key" {
  #checkov:skip=CKV2_AWS_57:run terraform apply to rotate hmac
  name                    = "${local.solution_prefix}-hcp_tf_api_key"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = aws_kms_key.ai_debugger_key.arn
  tags                    = local.combined_tags
}

resource "aws_secretsmanager_secret_version" "hcp_tf_api_key" {
  secret_id     = aws_secretsmanager_secret.hcp_tf_api_key.id
  secret_string = var.hcp_tf_token
}

resource "random_uuid" "ai_debugger_cloudfront" {
  count = local.waf_deployment
}

resource "aws_secretsmanager_secret" "ai_debugger_cloudfront" {
  #checkov:skip=CKV2_AWS_57:run terraform apply to rotate cloudfront secret
  count                   = local.waf_deployment
  name                    = "${local.solution_prefix}-ai_debugger_cloudfront"
  recovery_window_in_days = var.recovery_window
  kms_key_id              = aws_kms_key.ai_debugger_key.arn
  tags                    = local.combined_tags
}

resource "aws_secretsmanager_secret_version" "ai_debugger_cloudfront" {
  count         = local.waf_deployment
  secret_id     = aws_secretsmanager_secret.ai_debugger_cloudfront[count.index].id
  secret_string = random_uuid.ai_debugger_cloudfront[count.index].result
}
