"""
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

import json
import logging
import os
import re
import boto3

from urllib.parse import urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError
from botocore.exceptions import ClientError

HCP_TF_HOST_NAME = os.environ.get("HCP_TF_HOST_NAME", "app.terraform.io")

logger = logging.getLogger()
log_level = os.environ.get("log_level", logging.INFO)

logger.setLevel(log_level)
logger.info("Log level set to %s" % logger.getEffectiveLevel())


def lambda_handler(event, context):
    logger.debug(json.dumps(event))
    try:

        hcp_tf_api_key = get_hcp_tf_api_key(
            event["payload"]["fulfillment"]["hcp_tf_api_key_arn"]
        )

        logger.debug("Secrets manager: successfully retrieved HCP Terraform API key")

        # Send comment back to HCP Terraform
        comment_response = attach_comment(
            event["payload"]["fulfillment"]["content"],
            hcp_tf_api_key,
            event["payload"]["fulfillment"]["run_id"],
        )

        logging.info(
            f"Successfully created a comment in HCP Terraform. {comment_response}"
        )
        return "completed"

    except Exception as e:
        logger.exception("HCP Terraform callback error: {}".format(e))
        raise


def get_hcp_tf_api_key(hcp_tf_api_key_arn):
    hcp_tf_api_key = None

    session = boto3.session.Session()
    client = session.client(
        service_name="secretsmanager",
        region_name=os.environ.get("AWS_REGION", "us-east-1"),
    )

    try:
        get_secret_value_response = client.get_secret_value(SecretId=hcp_tf_api_key_arn)
    except ClientError as e:
        logging.exception("Exception: {}".format(e))
        return None

    return get_secret_value_response["SecretString"]


def attach_comment(comment, hcp_tf_api_key, run_id):
    """
    Attach a comment to the HCP Terraform run

    :param comment: The comment to attach to the run
    :param hcp_tf_api_key: HCP Terraform API access token
    :param run_id: The run id to attach the comment
    :return: response as string
    """
    message = ""
    try:
        headers = {
            "Authorization": f"Bearer {hcp_tf_api_key}",
            "Content-Type": "application/vnd.api+json",
        }

        url = f"https://{HCP_TF_HOST_NAME}/api/v2/runs/{run_id}/comments"
        data = {
            "data": {
                "attributes": {"body": comment},
                "type": "comments",
            }
        }

        response = requests.post(url, headers=headers, data=data)
        if 200 <= response.status_code < 300:
            comment_response_json = response.json()
            mesaage = f"Successfully created a comment in HCP Terraform."
        else:
            message = f"Failed creating comment in HCP Terraform, status code {response.status_code}."

    except Exception as e:
        logging.exception("Exception: {}".format(e))
        message = "Failed to create comment in HCP Terraform. Please check the Run id and Terraform API key."

    return message
