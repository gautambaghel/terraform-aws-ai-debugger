import json
import boto3
import botocore
import logging
import subprocess
import os

from utils import logger, stream_messages

# Initialize model_id and region
default_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
model_id = os.environ.get("BEDROCK_LLM_MODEL", default_model_id)
guardrail_id = os.environ.get("BEDROCK_GUARDRAIL_ID", None)
guardrail_version = os.environ.get("BEDROCK_GUARDRAIL_VERSION", None)

# Config to avoid timeouts when using long prompts
config = botocore.config.Config(
    read_timeout=1800, connect_timeout=1800, retries={"max_attempts": 0}
)

session = boto3.Session()
bedrock_client = session.client(service_name="bedrock-runtime", config=config)


# Input is the terraform plan JSON
def eval(tf_plan_err_msg):

    #####################################################################
    ##### Do generic evaluation of the Terraform plan error #####
    #####################################################################

    logger.info("##### Evaluating Terraform plan error #####")
    prompt = f"""Can you help with this Terraform error, please? {tf_plan_err_msg}"""

    system_text = "You are an assistant that helps with debugging Terraform errors."
    message_desc = [{"role": "user", "content": [{"text": prompt}]}]
    stop_reason, response = stream_messages(
        bedrock_client=bedrock_client,
        model_id=model_id,
        messages=message_desc,
        system_text=system_text,
        stop_sequences=["</result>"],
    )
    ai_response = response["content"][0]["text"]

    logger.info("##### Report #####")
    logger.info("Terraform plan error details: {}".format(ai_response))

    results = []

    guardrail_status, guardrail_response = guardrail_inspection(str(ai_response))
    if not guardrail_status:
        ai_response = "Bedrock guardrail triggered : {}".format(guardrail_response)

    return ai_response


def guardrail_inspection(input_text, input_mode="OUTPUT"):

    #####################################################################
    ##### Inspect input / output against Bedrock Guardrail          #####
    #####################################################################

    if guardrail_id and guardrail_version:
        logger.info(
            "##### Scanning Terraform plan error with Amazon Bedrock Guardrail #####"
        )

        response = bedrock_client.apply_guardrail(
            guardrailIdentifier=guardrail_id,
            guardrailVersion=guardrail_version,
            source=input_mode,
            content=[
                {
                    "text": {
                        "text": input_text,
                    }
                },
            ],
        )

        logger.debug("Guardrail inspection result : {}".format(json.dumps(response)))

        if response["action"] in ["GUARDRAIL_INTERVENED"]:
            logger.info("Guardrail action : {}".format(response["action"]))
            logger.info("Guardrail output : {}".format(response["outputs"]))
            logger.debug("Guardrail assessments : {}".format(response["assessments"]))
            return False, response["outputs"][0]["text"]

        elif response["action"] in ["NONE"]:
            logger.info("No Guardrail action required")
            return True, "No Guardrail action required"

    else:
        return True, "Guardrail inspection skipped"
