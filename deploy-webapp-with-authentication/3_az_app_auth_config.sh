#!/bin/sh
set -e

resource_group=$1
app_name=$2
client_id=$3
password=$4
tenant=$5

az webapp auth update -g $resource_group -n $app_name --enabled true \
  --action LoginWithAzureActiveDirectory \
  --aad-allowed-token-audiences "https://$app_name.azurewebsites.net" \
  --aad-client-id $client_id \
  --aad-client-secret $password \
  --aad-token-issuer-url "https://sts.windows.net/$tenant/"
