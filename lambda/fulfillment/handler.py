import os
import sys
import json
import time
import logging
import requests

import ai
import hcp_tf_utils

region = os.environ.get("AWS_REGION", None)
dev_mode = os.environ.get("DEV_MODE", "true")
hcp_tf_api_key_arn = os.environ.get("HCP_TF_API_KEY_ARN", None)  # required
log_level = os.environ.get("log_level", logging.INFO)

logger = logging.getLogger()
logger.setLevel(log_level)


# Main handler for the Lambda function
def lambda_handler(event, _):

    logger.debug(json.dumps(event, indent=4))

    try:

        if not hcp_tf_api_key_arn:
            raise ValueError(
                "HCP Terraform API key secret name is not set in the environment variables."
            )

        # Create a placeholder payload for callback lambda function
        ai_debugger_response = {
            "hcp_tf_api_key_arn": hcp_tf_api_key_arn,
            "content": "Placeholder content",
            "run_id": "unknown_run_id",
        }

        # Get Terraform API key from Secret Manager
        hcp_tf_api_key = hcp_tf_utils.get_hcp_tf_api_key(hcp_tf_api_key_arn)
        if not hcp_tf_api_key:
            ai_debugger_response["content"] = (
                f"Error retrieving HCP TF API token from AWS secrets manager. Please check the service logs for more details."
            )
            return ai_debugger_response

        logger.debug("Secrets manager: successfully retrieved HCP Terraform API key")

        run_id = event["payload"]["detail"]["run_id"]
        ai_debugger_response["run_id"] = run_id

        # Get error from HCP Terraform
        run_error_response = hcp_tf_utils.get_run_error(hcp_tf_api_key, run_id)
        if not run_error_response:
            ai_debugger_response["content"] = (
                f"No plan/apply error found in the HCP Terraform run."
            )
            return ai_debugger_response

        logger.debug("HCP Terraform run error: " + str(run_error_response))
        content = ai.eval(run_error_response)
        logger.info("AWS Bedrock response: " + str(content))

        # Deliver the payload to callback lambda function
        ai_debugger_response["content"] = content
        logger.debug(f"Delivering payload to callback Lambda Function {json.dumps(ai_debugger_response)}")

        return ai_debugger_response

    except Exception as e:
        logger.error(f"Error: {e}")

        run_id = (
            event.get("payload", {}).get("detail", {}).get("run_id", "unknown_run_id")
        )
        cw_log_group_name = os.environ.get("CW_LOG_GROUP_NAME", None)
        url = ""
        if cw_log_group_name and region:
            lg_name = cw_log_group_name.replace("/", "$252F")
            url = f"https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{lg_name}/log-events/{run_id}"

        ai_debugger_response = {
            "hcp_tf_api_key_arn": hcp_tf_api_key_arn,
            "content": (
                f"HCP Terraform AI debugger failed, please look into the service logs for more details. {url}"
            ),
            "run_id": run_id,
        }

        return ai_debugger_response
