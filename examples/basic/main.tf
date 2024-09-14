#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

data "aws_region" "current" {}

data "tfe_organization" "hcp_tf_org" {
  name = var.hcp_tf_org
}

module "hcp_tf_ai_debugger" {
  source                = "../.."
  aws_region            = data.aws_region.current.name
  hcp_tf_org            = data.tfe_organization.hcp_tf_org.name
  hcp_tf_token          = var.hcp_tf_token
  ai_debugger_iam_roles = var.tf_ai_debugger_logic_iam_roles
  deploy_waf            = true
}

resource "tfe_workspace" "demo_ws" {
  auto_apply   = true
  name         = "ai-debugger-demo"
  organization = data.tfe_organization.hcp_tf_org.name
}

resource "tfe_notification_configuration" "bedrock_ai_debugger" {
  enabled          = true
  name             = "Bedrock-AI-Debugger"
  destination_type = "generic"
  triggers         = ["run:errored"]
  url              = module.hcp_tf_ai_debugger.ai_debugger_url
  token            = module.hcp_tf_ai_debugger.ai_debugger_hmac
  workspace_id     = tfe_workspace.demo_ws.id
}
