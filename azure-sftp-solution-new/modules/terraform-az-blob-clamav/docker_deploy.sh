#!/bin/sh

git clone --depth=1 -b $GIT_REF https://github.com/KPMG-UK/docker-clamav-azure.git
cd docker-clamav-azure
TOKEN=$(az acr login --name $CONT_REG_NAME --expose-token --output tsv --query accessToken)
docker login -u 00000000-0000-0000-0000-000000000000 --password $TOKEN $CONT_REG_NAME.azurecr.io
docker build -t docker-clamav-azure .
docker tag docker-clamav-azure $CONT_REG_NAME.azurecr.io/docker-clamav-azure
docker push $CONT_REG_NAME.azurecr.io/docker-clamav-azure | tail -1
cd ..
rm -rf docker-clamav-azure