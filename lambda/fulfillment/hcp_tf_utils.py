import os
import re
import json
import tarfile
import hashlib
import logging
import requests
import time

from urllib.request import urlopen, Request
from urllib.error import HTTPError, URLError

logging.basicConfig(format="%(levelname)s: %(message)s")
logger = logging.getLogger()

hcp_tf_host_name = os.environ.get("HCP_TF_HOST_NAME", "app.terraform.io")


def get_run_error(hcp_tf_api_key: str, run_id: str) -> str:
    """
    Get Terraform run error via API

    :param hcp_tf_api_key: HCP Terraform API access token
    :param run_id: The run id to get the plan or apply error
    :return: response as dict
    """

    headers = {
        "Authorization": f"Bearer {hcp_tf_api_key}",
        "Content-Type": "application/vnd.api+json",
    }

    url = f"https://{hcp_tf_host_name}/api/v2/runs/{run_id}"
    response = requests.get(f"{url}/plan", headers=headers)
    try:
        if response.json()["data"]["attributes"]["status"] == "errored":
            logs_url = response.json()["data"]["attributes"]["log-read-url"]
            return requests.get(logs_url).text
    except KeyError:
        pass

    response = requests.get(f"{url}/apply", headers=headers)
    try:
        if response.json()["data"]["attributes"]["status"] == "errored":
            logs_url = response.json()["data"]["attributes"]["log-read-url"]
            return requests.get(logs_url).text
    except KeyError:
        pass

    return None


def validate_endpoint(endpoint):
    # validate that the endpoint hostname is valid
    pattern = r"^https://" + str(hcp_tf_host_name).replace(".", r"\.") + r"/.*"
    result = re.match(pattern, endpoint)
    return result


def convert_to_markdown(result):
    result = result.replace("\n", "<br>")
    result = result.replace("##", "<br>##")
    result = result.replace("*", "<br>*")
    result = result.replace("<br><br>", "<br>")
    return result


def log_helper(cwl_client, log_group_name, log_stream_name, log_message): # helper function to write AI debugger results to dedicated cloudwatch log group
    if log_group_name: # true if CW log group name is specified
        global SEQUENCE_TOKEN
        try:
            SEQUENCE_TOKEN = log_writer(cwl_client, log_group_name, log_stream_name, log_message, SEQUENCE_TOKEN)["nextSequenceToken"]
        except:
            cwl_client.create_log_stream(logGroupName = log_group_name,logStreamName = log_stream_name)
            SEQUENCE_TOKEN = log_writer(cwl_client, log_group_name, log_stream_name, log_message)["nextSequenceToken"]


def log_writer(cwl_client, log_group_name, log_stream_name, log_message, sequence_token = False): # writer to CloudWatch log stream based on sequence token
    if sequence_token: # if token exist, append to the previous token stream
        response = cwl_client.put_log_events(
            logGroupName = log_group_name,
            logStreamName = log_stream_name,
            logEvents = [{
                'timestamp' : int(round(time.time() * 1000)),
                'message' : time.strftime('%Y-%m-%d %H:%M:%S') + ": " + log_message
            }],
            sequenceToken = sequence_token
        )
    else: # new log stream, no token exist
        response = cwl_client.put_log_events(
            logGroupName = log_group_name,
            logStreamName = log_stream_name,
            logEvents = [{
                'timestamp' : int(round(time.time() * 1000)),
                'message' : time.strftime('%Y-%m-%d %H:%M:%S') + ": " + log_message
            }]
        )
    return response
