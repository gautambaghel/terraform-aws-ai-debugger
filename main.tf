resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}

#####################################################################################
# EVENT BRIDGE
#####################################################################################

resource "aws_cloudwatch_event_rule" "ai_debugger_rule" {
  name           = "${local.solution_prefix}-ai_debugger-rule"
  description    = "Rule to capture HCP Terraform AI debugger events"
  event_bus_name = var.event_bus_name
  event_pattern = templatefile("${path.module}/templates/ai_debugger_rule.tpl", {
    var_event_source = var.event_source
  })
  tags = local.combined_tags
}

resource "aws_cloudwatch_event_target" "ai_debugger_target" {
  rule           = aws_cloudwatch_event_rule.ai_debugger_rule.id
  event_bus_name = var.event_bus_name
  arn            = aws_sfn_state_machine.ai_debugger_states.arn
  role_arn       = aws_iam_role.ai_debugger_rule.arn
}

#####################################################################################
# STATE MACHINE
#####################################################################################

resource "aws_sfn_state_machine" "ai_debugger_states" {
  name     = "${local.solution_prefix}-ai_debugger-statemachine"
  role_arn = aws_iam_role.ai_debugger_states.arn
  definition = templatefile("${path.module}/templates/ai_debugger_states.asl.json", {
    resource_request     = aws_lambda_function.ai_debugger_request.arn
    resource_fulfillment = aws_lambda_function.ai_debugger_fulfillment.arn
    resource_callback    = aws_lambda_function.ai_debugger_callback.arn
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.ai_debugger_states.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  tracing_configuration {
    enabled = true
  }

  tags = local.combined_tags
}

resource "aws_cloudwatch_log_group" "ai_debugger_states" {
  name              = "/aws/vendedlogs/states/${local.solution_prefix}-ai_debugger-statemachine"
  retention_in_days = var.cloudwatch_log_group_retention
  kms_key_id        = aws_kms_key.ai_debugger_key.arn
  tags              = local.combined_tags
}
