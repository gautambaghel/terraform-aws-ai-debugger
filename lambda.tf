#####################################################################################
# LAMBDA
#####################################################################################

resource "terraform_data" "bootstrap" {
  provisioner "local-exec" {
    command = "cd ${path.module} && make build"
  }
}

################# AI Debugger EventBridge ##################
resource "aws_lambda_function" "ai_debugger_eventbridge" {
  function_name    = "${local.solution_prefix}-ai_debugger-eventbridge"
  description      = "HCP Terraform ai debugger - EventBridge handler"
  role             = aws_iam_role.ai_debugger_eventbridge.arn
  architectures    = local.lambda_architecture
  source_code_hash = data.archive_file.ai_debugger_eventbridge.output_base64sha256
  filename         = data.archive_file.ai_debugger_eventbridge.output_path
  handler          = "handler.lambda_handler"
  runtime          = local.lambda_python_runtime
  timeout          = local.lambda_default_timeout
  environment {
    variables = {
      HCP_TF_HMAC_SECRET_ARN = aws_secretsmanager_secret.ai_debugger_hmac.arn
      HCP_TF_USE_WAF         = var.deploy_waf ? "True" : "False"
      HCP_TF_CF_SECRET_ARN   = var.deploy_waf ? aws_secretsmanager_secret.ai_debugger_cloudfront[0].arn : null
      HCP_TF_CF_SIGNATURE    = var.deploy_waf ? local.cloudfront_sig_name : null
      EVENT_BUS_NAME         = var.event_bus_name
    }
  }
  tracing_config {
    mode = "Active"
  }
  reserved_concurrent_executions = local.lambda_reserved_concurrency
  tags                           = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ
  #checkov:skip=CKV_AWS_117:VPC is not required
  #checkov:skip=CKV_AWS_173:non sensitive environment variables
  #checkov:skip=CKV_AWS_272:skip code-signing
}

resource "aws_lambda_function_url" "ai_debugger_eventbridge" {
  function_name      = aws_lambda_function.ai_debugger_eventbridge.function_name
  authorization_type = "AWS_IAM"
  #checkov:skip=CKV_AWS_258:auth set to none, validation hmac inside the lambda code
}

resource "aws_lambda_permission" "ai_debugger_eventbridge" {
  count         = local.waf_deployment
  statement_id  = "AllowCloudFrontToFunctionUrl"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.ai_debugger_eventbridge.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = module.ai_debugger_cloudfront[count.index].cloudfront_distribution_arn
}

resource "aws_cloudwatch_log_group" "ai_debugger_eventbridge" {
  name              = "/aws/lambda/${aws_lambda_function.ai_debugger_eventbridge.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}

################# AI Debugger request ##################
resource "aws_lambda_function" "ai_debugger_request" {
  function_name                  = "${local.solution_prefix}-ai_debugger-request"
  description                    = "HCP Terraform ai debugger - Request handler"
  role                           = aws_iam_role.ai_debugger_request.arn
  architectures                  = local.lambda_architecture
  source_code_hash               = data.archive_file.ai_debugger_request.output_base64sha256
  filename                       = data.archive_file.ai_debugger_request.output_path
  handler                        = "handler.lambda_handler"
  runtime                        = local.lambda_python_runtime
  timeout                        = local.lambda_default_timeout
  reserved_concurrent_executions = local.lambda_reserved_concurrency
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      HCP_TF_ORG       = var.hcp_tf_org
      WORKSPACE_PREFIX = length(var.workspace_prefix) > 0 ? var.workspace_prefix : null
    }
  }
  tags = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ
  #checkov:skip=CKV_AWS_117:VPC is not required
  #checkov:skip=CKV_AWS_173:no sensitive data in env var
  #checkov:skip=CKV_AWS_272:skip code-signing
}

resource "aws_cloudwatch_log_group" "ai_debugger_request" {
  name              = "/aws/lambda/${aws_lambda_function.ai_debugger_request.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}

################# AI Debugger callback ##################
resource "aws_lambda_function" "ai_debugger_callback" {
  function_name                  = "${local.solution_prefix}-ai_debugger-callback"
  description                    = "HCP Terraform ai debugger - Callback handler"
  role                           = aws_iam_role.ai_debugger_callback.arn
  architectures                  = local.lambda_architecture
  source_code_hash               = data.archive_file.ai_debugger_callback.output_base64sha256
  filename                       = data.archive_file.ai_debugger_callback.output_path
  handler                        = "handler.lambda_handler"
  runtime                        = local.lambda_python_runtime
  timeout                        = local.lambda_default_timeout
  reserved_concurrent_executions = local.lambda_reserved_concurrency
  tracing_config {
    mode = "Active"
  }
  tags = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ
  #checkov:skip=CKV_AWS_117:VPC is not required
  #checkov:skip=CKV_AWS_272:skip code-signing
}

resource "aws_cloudwatch_log_group" "ai_debugger_callback" {
  name              = "/aws/lambda/${aws_lambda_function.ai_debugger_callback.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}

################# AI Debugger Edge ##################
resource "aws_lambda_function" "ai_debugger_edge" {
  provider                       = aws.cloudfront_waf
  function_name                  = "${local.solution_prefix}-ai_debugger-edge"
  description                    = "HCP Terraform ai debugger - Lambda@Edge handler"
  role                           = aws_iam_role.ai_debugger_edge.arn
  architectures                  = local.lambda_architecture
  source_code_hash               = data.archive_file.ai_debugger_edge.output_base64sha256
  filename                       = data.archive_file.ai_debugger_edge.output_path
  handler                        = "handler.lambda_handler"
  runtime                        = local.lambda_python_runtime
  timeout                        = 5 # Lambda@Edge max timout is 5
  reserved_concurrent_executions = local.lambda_reserved_concurrency
  publish                        = true # Lambda@Edge must be published
  tags                           = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ
  #checkov:skip=CKV_AWS_117:VPC is not required
  #checkov:skip=CKV_AWS_173:no sensitive data in env var
  #checkov:skip=CKV_AWS_272:skip code-signing
  #checkov:skip=CKV_AWS_50:no x-ray for lambda@edge
}

################# AI Debugger Fulfillment ##################
resource "aws_lambda_function" "ai_debugger_fulfillment" {
  function_name                  = "${local.solution_prefix}-ai_debugger-fulfillment"
  description                    = "HCP Terraform ai debugger - Fulfillment handler"
  role                           = aws_iam_role.ai_debugger_fulfillment.arn
  architectures                  = local.lambda_architecture
  source_code_hash               = data.archive_file.ai_debugger_fulfillment.output_base64sha256
  filename                       = data.archive_file.ai_debugger_fulfillment.output_path
  handler                        = "handler.lambda_handler"
  runtime                        = local.lambda_python_runtime
  timeout                        = local.lambda_default_timeout
  reserved_concurrent_executions = local.lambda_reserved_concurrency
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      CW_LOG_GROUP_NAME         = local.cloudwatch_log_group_name
      hcp_tf_secret_name        = aws_secretsmanager_secret.ai_debugger_hmac.name
      BEDROCK_LLM_MODEL         = var.bedrock_llm_model
      BEDROCK_GUARDRAIL_ID      = awscc_bedrock_guardrail.ai_debugger_fulfillment.guardrail_id
      BEDROCK_GUARDRAIL_VERSION = awscc_bedrock_guardrail_version.ai_debugger_fulfillment.version
    }
  }
  tags = local.combined_tags
  #checkov:skip=CKV_AWS_116:not using DLQ
  #checkov:skip=CKV_AWS_117:VPC is not required
  #checkov:skip=CKV_AWS_173:no sensitive data in env var
  #checkov:skip=CKV_AWS_272:skip code-signing
}

resource "aws_cloudwatch_log_group" "ai_debugger_fulfillment" {
  name              = "/aws/lambda/${aws_lambda_function.ai_debugger_fulfillment.function_name}"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}

resource "aws_cloudwatch_log_group" "ai_debugger_fulfillment_output" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}
