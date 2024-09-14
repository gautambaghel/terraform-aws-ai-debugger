import os
import sys
import json
import time
import logging
import requests
import boto3

import ai
import hcp_tf_utils

region = os.environ.get("AWS_REGION", None)
dev_mode = os.environ.get("DEV_MODE", "true")
hcp_tf_secret_name = os.environ.get("hcp_tf_secret_name", None) #required
log_level = os.environ.get("log_level", logging.INFO)

logger = logging.getLogger()
logger.setLevel(log_level)

session = boto3.Session()
cwl_client = session.client("logs")


# Main handler for the Lambda function
def lambda_handler(event, _):

    logger.debug(json.dumps(event, indent=4))

    try:

        if not hcp_tf_secret_name:
            raise ValueError("HCP Terraform API key secret name is not set in the environment variables.")

        run_id = payload["run_id"]
        tfc_api_secret_name = payload["tfc_api_secret_name"]

        # Deliver the payload for callback lambda function
        ai_debugger_response = {
            "hcp_tf_api_secret_name": hcp_tf_api_secret_name,
            "content": "Placeholder content",
            "run_id": run_id,
        }

        # Get Terraform API key from Secret Manager
        hcp_tf_api_key = get_hcp_tf_api_key(
            hcp_tf_secret_name
        )
        if not hcp_tf_api_key:
            ai_debugger_response["content"] = (
                f"Error retrieving token from AWS secrets manager. Please check the service logs for more details."
            )
            return ai_debugger_response
        
        logger.debug(
                "Secrets manager: successfully retrieved Terraform Cloud API key"
            )

        # Get error from Terraform Cloud
        run_error_response = hcp_tf_utils.get_run_error(hcp_tf_api_key, run_id)
        if not run_error_response:
            return send_cloud_funtion_response(
                "No plan/apply error found in the Terraform Cloud run", 422, "error"
            )
        logger.debug("HCP Terraform run error: " + str(run_error_response))

        content = ai.eval(data)

        logger.info("AWS Bedrock response: " + str(content))
        logger.debug("Delivering payload to callback Lambda Function")

        # Deliver the payload for callback lambda function
        ai_debugger_response["content"] = content
        return ai_debugger_response

    except Exception as e:
        logger.error(f"Error: {e}")

        cw_log_group_name = os.environ.get("CW_LOG_GROUP_NAME", None)
        if cw_log_group_name and region:
            lg_name = cw_log_group_name.replace("/", "$252F")
            url = f"https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{lg_name}/log-events/{run_id}"


        run_id = payload["run_id"]
        tfc_api_secret_name = payload["tfc_api_secret_name"]
        ai_debugger_response["content"] = (
            f"HCP Terraform AI debugger failed, please look into the service logs for more details. ${url}"
        )
        ai_debugger_response = {
            "tfc_api_secret_name": tfc_api_secret_name,
            "content": content,
            "run_id": run_id,
        }
        return ai_debugger_response


def get_hcp_tf_api_key(hcp_tf_api_secret_name):
    hcp_tf_api_secret_name = ""

    try:
        client = boto3.client('secretsmanager')
        response = client.get_secret_value(SecretId=hcp_tf_api_secret_name)
        hcp_tf_api_secret_name = response['SecretString']

    except Exception as e:
        logging.exception("Exception: {}".format(e))
        message = "Failed to get the HCP Terraform API key. Please check the secrets manager id and HCP Terraform API key priviledges."
        return None

    return hcp_tf_api_secret_name
