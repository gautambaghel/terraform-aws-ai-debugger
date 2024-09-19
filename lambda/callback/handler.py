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
            event["payload"]["result"]["fulfillment"]["hcp_tf_api_key_arn"]
        )

        if not hcp_tf_api_key:
            logger.error(
                f"Error retrieving HCP TF API token from AWS secrets manager. Please check the service logs for more details."
            )
            return "completed"

        logger.debug("Secrets manager: successfully retrieved HCP Terraform API key")

        # Send comment back to HCP Terraform
        comment_response = attach_comment(
            event["payload"]["result"]["fulfillment"]["content"],
            hcp_tf_api_key,
            event["payload"]["result"]["fulfillment"]["run_id"],
        )

        logger.info("HCP Terraform response: {}".format(comment_response))
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
    headers = {
        "Authorization": f"Bearer {hcp_tf_api_key}",
        "Content-Type": "application/vnd.api+json",
    }

    url = f"https://{HCP_TF_HOST_NAME}/api/v2/runs/{run_id}/comments"
    payload = {
        "data": {
            "attributes": {"body": f"{comment}"},
            "type": "comments",
        }
    }
    data = bytes(json.dumps(payload), encoding="utf-8")
    request = Request(url, headers=headers, data=data, method="POST")
    try:
        if validate_endpoint(url):
            with urlopen(request, timeout=10) as response:  # nosec URL validation
                return response.read()
        else:
            raise URLError(
                f"Invalid endpoint URL, expected host is: {HCP_TF_HOST_NAME}"
            )
    except HTTPError as error:
        logger.error(f"HTTPError: {error.status} - {error.reason}")
    except URLError as error:
        logger.error(f"URLError: {error.reason}")
    except TimeoutError:
        logger.error("Request timed out")

    return "Failed to create comment in HCP Terraform. Please check the Run Id and Terraform API key."


def validate_endpoint(endpoint):  # validate that the endpoint hostname is valid
    pattern = "^https:\/\/" + str(HCP_TF_HOST_NAME).replace(".", "\.") + "\/" + ".*"
    result = re.match(pattern, endpoint)
    return result
