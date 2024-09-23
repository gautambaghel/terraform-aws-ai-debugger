<!-- BEGIN_TF_DOCS -->
# Usage Example

Follow the steps below to deploy the module and attach it to your HCP Terraform (prev. Terraform Cloud) organization.

* Build and package the Lambda files

  ```
  make all
  ```

* Deploy the module

  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

* (Optional, if using HCP Terraform) Add the cloud block in `providers.tf`

  ```hcl
  terraform {

    cloud {
      # TODO: Change this to your HCP Terraform org name.
      organization = "<enter your org name here>"
      workspaces {
        ...
      }
    }
    ...
  }
  ```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.56.1 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~>0.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.56.1 |
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~>0.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hcp_tf_ai_debugger"></a> [hcp\_tf\_ai\_debugger](#module\_hcp\_tf\_ai\_debugger) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [tfe_notification_configuration.bedrock_ai_debugger](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/notification_configuration) | resource |
| [tfe_workspace.demo_ws](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/data-sources/region) | data source |
| [tfe_oauth_client.hcp_tf_client](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/oauth_client) | data source |
| [tfe_organization.hcp_tf_org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hcp_tf_org"></a> [hcp\_tf\_org](#input\_hcp\_tf\_org) | HCP Terraform Organization name | `string` | n/a | yes |
| <a name="input_hcp_tf_token"></a> [hcp\_tf\_token](#input\_hcp\_tf\_token) | HCP Terraform API token | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |
| <a name="input_tf_ai_debugger_logic_iam_roles"></a> [tf\_ai\_debugger\_logic\_iam\_roles](#input\_tf\_ai\_debugger\_logic\_iam\_roles) | values for the IAM roles to be used by the AI debugger logic | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_debugger_url"></a> [ai\_debugger\_url](#output\_ai\_debugger\_url) | n/a |
<!-- END_TF_DOCS -->
