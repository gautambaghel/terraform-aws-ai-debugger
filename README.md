<!-- BEGIN_TF_DOCS -->
# terraform-aws-ai-debugger

The AI debugger for Terraform is a solution designed to address runtime issues, enhancing the identification and resolution of challenges in deploying infrastructure through Terraform. It leverages AWS and HCP Terraform to optimize the remediation process.

![Demo](./images/aws-ai-debugger-demo.gif)

## Architecture

The diagram below shows the Terraform AI debugger components leveraging low cost serverless AWS resources.

![Diagram](./images/ai-debugger.png)

Resources created in AWS are:

* Bedrock - Anthropic Claude 3 sonnet
* Lambda Functions - request, fulfillment, call back, edge (optional)
* Step functions
* Secrets Manager
* Eventbridge
* Cloudfront
* WAFv2 (optional)

## Prerequisites

To use this module you need have the following:

1. AWS account and credentials with Bedrock - Anthropic Claude enabled
1. HCP Terraform account

## Usage

1. Reference the `examples/basic` folder on how to use this module

    ```sh
    cd examples/basic
    terraform init
    terraform plan
    terraform apply
    ```

## Best practice

* **Do not** re-use the the endpoint URL across different trust-boundary (organizations, accounts, team). We recommend you to deploy separate the AI debugger deployment per trust-boundary.

* **Do not** use AI debugger URL from untrusted party, remember that execution is sent HCP Terraform to the AI debugger endpoint. Only use trusted URLs.

* Enable the AWS WAF setup by setting variable `deploy_waf` to `true` (additional cost will apply). This will add WAF protection to the AI debugger URL endpoint.

* We recommend you to setup additional CloudWatch alarm to monitor Lambda concurrency and WAF rules.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~>2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.47.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.11.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~>2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.47.0 |
| <a name="provider_aws.cloudfront_waf"></a> [aws.cloudfront\_waf](#provider\_aws.cloudfront\_waf) | >= 5.47.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_debugger_cloudfront"></a> [ai\_debugger\_cloudfront](#module\_ai\_debugger\_cloudfront) | terraform-aws-modules/cloudfront/aws | 3.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_origin_request_policy.ai_debugger_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudwatch_event_rule.ai_debugger_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ai_debugger_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_fulfillment_output](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_iam_role.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ai_debugger_states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ai_debugger_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ai_debugger_states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_fulfillment_additional_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_fulfillment_basic_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_fulfillment_bedrock_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ai_debugger_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.ai_debugger_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ai_debugger_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.ai_debugger_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.ai_debugger_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.ai_debugger_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.ai_debugger_hmac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.hcp_tf_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.ai_debugger_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.ai_debugger_hmac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.hcp_tf_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_sfn_state_machine.ai_debugger_states](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_wafv2_web_acl.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [awscc_bedrock_guardrail.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_guardrail) | resource |
| [awscc_bedrock_guardrail_version.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_guardrail_version) | resource |
| [random_string.solution_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_uuid.ai_debugger_cloudfront](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.ai_debugger_hmac](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [terraform_data.bootstrap](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_1800_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [archive_file.ai_debugger_callback](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.ai_debugger_edge](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.ai_debugger_eventbridge](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.ai_debugger_fulfillment](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.ai_debugger_request](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.bedrock_full_access_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.lambda_basic_execution_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.ai_debugger_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ai_debugger_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ai_debugger_waf_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.cloudfront_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region from which this module will be executed. | `string` | n/a | yes |
| <a name="input_hcp_tf_org"></a> [hcp\_tf\_org](#input\_hcp\_tf\_org) | HCP Terraform Organization name | `string` | n/a | yes |
| <a name="input_hcp_tf_token"></a> [hcp\_tf\_token](#input\_hcp\_tf\_token) | HCP Terraform API token | `string` | n/a | yes |
| <a name="input_ai_debugger_iam_roles"></a> [ai\_debugger\_iam\_roles](#input\_ai\_debugger\_iam\_roles) | List of IAM roles to be attached to the Lambda function | `list(string)` | `null` | no |
| <a name="input_bedrock_llm_model"></a> [bedrock\_llm\_model](#input\_bedrock\_llm\_model) | Bedrock LLM model to use | `string` | `"anthropic.claude-3-sonnet-20240229-v1:0"` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | AI debugger CloudWatch log group name | `string` | `"/hashicorp/terraform/ai-debugger/"` | no |
| <a name="input_cloudwatch_log_group_retention"></a> [cloudwatch\_log\_group\_retention](#input\_cloudwatch\_log\_group\_retention) | Lambda CloudWatch log group retention period | `string` | `"365"` | no |
| <a name="input_deploy_waf"></a> [deploy\_waf](#input\_deploy\_waf) | Set to true to deploy CloudFront and WAF in front of the Lambda function URL | `string` | `false` | no |
| <a name="input_event_bus_name"></a> [event\_bus\_name](#input\_event\_bus\_name) | EventBridge event bus name | `string` | `"default"` | no |
| <a name="input_event_source"></a> [event\_source](#input\_event\_source) | EventBridge source name | `string` | `"app.terraform.io"` | no |
| <a name="input_lambda_architecture"></a> [lambda\_architecture](#input\_lambda\_architecture) | Lambda architecture (arm64 or x86\_64) | `string` | `"x86_64"` | no |
| <a name="input_lambda_default_timeout"></a> [lambda\_default\_timeout](#input\_lambda\_default\_timeout) | Lambda default timeout in seconds | `number` | `120` | no |
| <a name="input_lambda_python_runtime"></a> [lambda\_python\_runtime](#input\_lambda\_python\_runtime) | Lambda Python runtime | `string` | `"python3.11"` | no |
| <a name="input_lambda_reserved_concurrency"></a> [lambda\_reserved\_concurrency](#input\_lambda\_reserved\_concurrency) | Maximum Lambda reserved concurrency, make sure your AWS quota is sufficient | `number` | `10` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name to be used on all the resources as identifier. | `string` | `"tf-ai-debugger"` | no |
| <a name="input_recovery_window"></a> [recovery\_window](#input\_recovery\_window) | Numbers of day Number of days that AWS Secrets Manager waits before it can delete the secret | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to resources deployed by this solution. | `map(any)` | `null` | no |
| <a name="input_waf_managed_rule_set"></a> [waf\_managed\_rule\_set](#input\_waf\_managed\_rule\_set) | List of AWS Managed rules to use inside the WAF ACL | `list(map(string))` | <pre>[<br>  {<br>    "metric_suffix": "common",<br>    "name": "AWSManagedRulesCommonRuleSet",<br>    "priority": 10,<br>    "vendor_name": "AWS"<br>  },<br>  {<br>    "metric_suffix": "bad_input",<br>    "name": "AWSManagedRulesKnownBadInputsRuleSet",<br>    "priority": 20,<br>    "vendor_name": "AWS"<br>  }<br>]</pre> | no |
| <a name="input_waf_rate_limit"></a> [waf\_rate\_limit](#input\_waf\_rate\_limit) | Rate limit for request coming to WAF | `number` | `100` | no |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | HCP Terraform workspace name prefix that allowed to run the AI debugger | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_debugger_hmac"></a> [ai\_debugger\_hmac](#output\_ai\_debugger\_hmac) | HCP Terraform HMAC key value, keep this sensitive data safe |
| <a name="output_ai_debugger_url"></a> [ai\_debugger\_url](#output\_ai\_debugger\_url) | The Terraform AI debugger URL endpoint, you can use this to configure the notification webhook setup in HCP Terraform |
<!-- END_TF_DOCS -->
