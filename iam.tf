################# IAM for ai debugger Lambda@Edge ##################
resource "aws_iam_role" "ai_debugger_edge" {
  name               = "${local.solution_prefix}-ai_debugger-edge"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/lambda_edge.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy_attachment" "ai_debugger_edge" {
  count      = length(local.lambda_managed_policies)
  role       = aws_iam_role.ai_debugger_edge.name
  policy_arn = local.lambda_managed_policies[count.index]
}

################# IAM for ai debugger EventBridge ##################
resource "aws_iam_role" "ai_debugger_eventbridge" {
  name               = "${local.solution_prefix}-ai_debugger-eventbridge"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/lambda.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy_attachment" "ai_debugger_eventbridge" {
  count      = length(local.lambda_managed_policies)
  role       = aws_iam_role.ai_debugger_eventbridge.name
  policy_arn = local.lambda_managed_policies[count.index]
}

resource "aws_iam_role_policy" "ai_debugger_eventbridge" {
  name = "${local.solution_prefix}-ai_debugger-eventbridge-policy"
  role = aws_iam_role.ai_debugger_eventbridge.id
  policy = templatefile("${path.module}/templates/role-policies/ai-debugger-eventbridge-lambda-role-policy.tpl", {
    data_aws_region          = data.aws_region.current_region.name
    data_aws_account_id      = data.aws_caller_identity.current_account.account_id
    data_aws_partition       = data.aws_partition.current_partition.partition
    var_event_bus_name       = var.event_bus_name
    resource_ai_debugger_secrets = var.deploy_waf ? [aws_secretsmanager_secret.ai_debugger_hmac.arn, aws_secretsmanager_secret.ai_debugger_cloudfront[0].arn] : [aws_secretsmanager_secret.ai_debugger_hmac.arn]
  })
}

################# IAM for ai debugger request ##################
resource "aws_iam_role" "ai_debugger_request" {
  name               = "${local.solution_prefix}-ai_debugger-request"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/lambda.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy_attachment" "ai_debugger_request" {
  count      = length(local.lambda_managed_policies)
  role       = aws_iam_role.ai_debugger_request.name
  policy_arn = local.lambda_managed_policies[count.index]
}

################# IAM for ai debugger callback ##################
resource "aws_iam_role" "ai_debugger_callback" {
  name               = "${local.solution_prefix}-ai_debugger-callback"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/lambda.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy_attachment" "ai_debugger_callback" {
  count      = length(local.lambda_managed_policies)
  role       = aws_iam_role.ai_debugger_callback.name
  policy_arn = local.lambda_managed_policies[count.index]
}

################# IAM for ai debugger fulfillment ##################
resource "aws_iam_role" "ai_debugger_fulfillment" {
  name               = "${local.solution_prefix}-ai_debugger-fulfillment"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/lambda.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy_attachment" "ai_debugger_fulfillment_basic_attachment" {
  count      = length(local.lambda_managed_policies)
  role       = aws_iam_role.ai_debugger_fulfillment.name
  policy_arn = local.lambda_managed_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "ai_debugger_fulfillment_bedrock_attachment" {
  count      = length(local.lambda_bedrock_managed_policies)
  role       = aws_iam_role.ai_debugger_fulfillment.name
  policy_arn = local.lambda_bedrock_managed_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "ai_debugger_fulfillment_additional_attachment" {
  # Customer can add additional permissions
  count      = length(var.ai_debugger_iam_roles)
  role       = aws_iam_role.ai_debugger_fulfillment.name
  policy_arn = var.ai_debugger_iam_roles[count.index]
}

resource "aws_iam_role_policy" "ai_debugger_fulfillment" {
  name = "${local.solution_prefix}-ai_debugger-fulfillment-policy"
  role = aws_iam_role.ai_debugger_fulfillment.id
  policy = templatefile("${path.module}/templates/role-policies/ai-debugger-fulfillment-lambda-role-policy.tpl", {
    data_aws_region      = data.aws_region.current_region.name
    data_aws_account_id  = data.aws_caller_identity.current_account.account_id
    data_aws_partition   = data.aws_partition.current_partition.partition
    local_log_group_name = local.cloudwatch_log_group_name
  })
}

################# IAM for ai debugger StateMachine ##################
resource "aws_iam_role" "ai_debugger_states" {
  name               = "${local.solution_prefix}-ai_debugger-statemachine"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/states.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy" "ai_debugger_states" {
  name = "${local.solution_prefix}-ai_debugger-statemachine-policy"
  role = aws_iam_role.ai_debugger_states.id
  policy = templatefile("${path.module}/templates/role-policies/ai-debugger-state-role-policy.tpl", {
    data_aws_region     = data.aws_region.current_region.name
    data_aws_account_id = data.aws_caller_identity.current_account.account_id
    data_aws_partition  = data.aws_partition.current_partition.partition
    var_name_prefix     = var.name_prefix
  })
}


################# IAM for ai debugger EventBridge rule ##################
resource "aws_iam_role" "ai_debugger_rule" {
  name               = "${local.solution_prefix}-ai_debugger-rule"
  assume_role_policy = templatefile("${path.module}/templates/trust-policies/events.tpl", { none = "none" })
  tags               = local.combined_tags
}

resource "aws_iam_role_policy" "ai_debugger_rule" {
  name = "${local.solution_prefix}-ai_debugger-rule-policy"
  role = aws_iam_role.ai_debugger_rule.id
  policy = templatefile("${path.module}/templates/role-policies/ai-debugger-rule-role-policy.tpl", {
    resource_ai_debugger_states = aws_sfn_state_machine.ai_debugger_states.arn
  })
}
