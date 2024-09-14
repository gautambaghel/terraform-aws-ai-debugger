#####################################################################################
# KMS
#####################################################################################

resource "aws_kms_key" "ai_debugger_key" {
  description         = "KMS key for ai debugger integration"
  policy              = data.aws_iam_policy_document.ai_debugger_key.json
  enable_key_rotation = true
  tags                = local.combined_tags
}

# Assign an alias to the key
resource "aws_kms_alias" "ai_debugger_key" {
  name          = "alias/TerraformAIDebuggerKey"
  target_key_id = aws_kms_key.ai_debugger_key.key_id
}

resource "aws_kms_key" "ai_debugger_waf" {
  count               = local.waf_deployment
  provider            = aws.cloudfront_waf
  description         = "KMS key for WAF"
  policy              = data.aws_iam_policy_document.ai_debugger_waf[count.index].json
  enable_key_rotation = true
  tags                = local.combined_tags
}

# Assign an alias to the key
resource "aws_kms_alias" "ai_debugger_waf" {
  count         = local.waf_deployment
  provider      = aws.cloudfront_waf
  name          = "alias/TerraformAIDebugger-WAF"
  target_key_id = aws_kms_key.ai_debugger_waf[count.index].key_id
}
