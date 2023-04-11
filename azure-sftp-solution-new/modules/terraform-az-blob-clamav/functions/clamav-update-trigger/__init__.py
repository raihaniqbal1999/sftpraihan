import logging
import time
import datetime
import os

import azure.functions as func
from azure.identity._credentials.managed_identity import ManagedIdentityCredential
from azure.mgmt.containerinstance import ContainerInstanceManagementClient
from azure.identity import DefaultAzureCredential

# Acquire the logger for a library (azure.mgmt.resource in this example)
logger = logging.getLogger("azure.mgmt.resource")

# Set the desired logging level
logger.setLevel(logging.DEBUG)


def main(timer: func.TimerRequest) -> None:

    # get env vars
    subID = os.environ["SUBSCRIPTION_ID"]
    resGroup = os.environ["RESOURCE_GROUP"]
    updateContGroup = os.environ["UPDATE_CONTAINER_GROUP"]

    utc_timestamp = (
        datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    )

    logger.info("Freshclam update triggered at {0}".format(utc_timestamp))

    cred = get_credential()

    aci_client = ContainerInstanceManagementClient(
        credential=cred, subscription_id=subID
    )
    aci = aci_client.container_groups.list_by_resource_group(resGroup)
    for container_group in aci:
        logger.info("  {0}".format(container_group.name))

    update_cg = aci_client.container_groups.get(resGroup, updateContGroup)

    for container in update_cg.containers:
        logger.info(container.name)
        logger.info(container.instance_view.current_state.state)

    if update_cg.containers[0].instance_view.current_state.state == "Running":
        logger.info("Container is in 'Running' state, cancelling start job.")
    else:
        start_containers(aci_client, resGroup, updateContGroup)


# disable vscode creds we should have ManagedIdentity (Azure) or AzureCliCredential (local)
# for local testing user must login with "az login" and "az account set --subscription XYZ"
def get_credential():
    logger.debug("Attempting to get credentials")
    return DefaultAzureCredential(exclude_visual_studio_code_credential=True)


def start_containers(client, resource_group, container_group):
    logger.debug(
        "Starting containers in '{0}' container group...".format(container_group)
    )
    job = client.container_groups.begin_start(resource_group, container_group)
    # wait for the status
    while job.done() is False:
        time.sleep(1)

    logger.debug(job.status())

    if job.status() != "Succeeded":
        logger.error(
            "Failed to start update job for ClamAV, please check container logs."
        )
    else:
        logger.info("Update job for ClamAV successfully started.")
