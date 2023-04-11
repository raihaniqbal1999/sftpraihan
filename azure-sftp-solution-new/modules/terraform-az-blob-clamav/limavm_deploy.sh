#!/bin/sh

git clone --depth=1 -b $GIT_REF https://github.com/KPMG-UK/docker-clamav-azure.git
cd docker-clamav-azure
limactl start
TOKEN=$(az acr login --name dockerclamavazure --expose-token --output tsv --query accessToken)
lima nerdctl login -u 00000000-0000-0000-0000-000000000000 --password $TOKEN dockerclamavazure.azurecr.io
lima nerdctl build -t docker-clamav-azure .
lima nerdctl tag docker-clamav-azure dockerclamavazure.azurecr.io/docker-clamav-azure
lima nerdctl push dockerclamavazure.azurecr.io/docker-clamav-azure | tail -1
cd ..
rm -rf docker-clamav-azure