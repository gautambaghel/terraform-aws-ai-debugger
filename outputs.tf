output "ai_debugger_hmac" {
  value       = aws_secretsmanager_secret_version.ai_debugger_hmac.secret_string
  description = "HMAC key value, keep this sensitive data safe"
  sensitive   = true
}

output "ai_debugger_url" {
  value       = var.deploy_waf ? "https://${module.ai_debugger_cloudfront[0].cloudfront_distribution_domain_name}" : trim(aws_lambda_function_url.ai_debugger_eventbridge.function_url, "/")
  description = "The Terraform AI debugger URL endpoint, you can use this to configure the notification webhook setup in HCP Terraform"
}
