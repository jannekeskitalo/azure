#!/bin/sh
set -e

app_name=$1

app_create_response=$(az ad app create \
    --display-name $app_name \
    --homepage "https://$app_name.azurewebsites.net" \
    --reply-urls "https://$app_name.azurewebsites.net/.auth/login/aad/callback")

client_id=$(echo $app_create_response | jq -r '.appId')

sp_create_response=$(az ad sp create --id $client_id --output json)
sp_reset_response=$(az ad sp credential reset --name $app_name --output json)
password=$(echo $sp_reset_response | jq -r '.password')
tenant=$(echo $sp_reset_response | jq -r '.tenant')

# Grant: Azure Active Directory Graph / User.Read -privilege
# To get the API ids, add the permission in the Portal and inspect the Application Manifest
az ad app permission add --id $client_id --api 00000002-0000-0000-c000-000000000000 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope

# Doesn't seem to require this:
# az ad app permission grant --id 345dc654-f801-4578-a9a0-493095989919 --api 00000002-0000-0000-c000-000000000000

echo "{\"client_id\": \"$client_id\", \"password\": \"$password\", \"tenant\": \"$tenant\"}"