variable "hcp_tf_org" {
  type        = string
  description = "HCP Terraform Organization name"
}

variable "hcp_tf_token" {
  type        = string
  sensitive   = true
  description = "HCP Terraform API token"
}

variable "tf_ai_debugger_logic_iam_roles" {
  type        = list(string)
  description = "values for the IAM roles to be used by the AI debugger logic"
  default     = []
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}
