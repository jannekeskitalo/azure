#!/bin/sh
set -e

# This script creates the whole stack, the app and the AD service principal.
# You need to have privileges to the create the resource group, app service and AD app registration

# Rquirements:
# Azure CLI
# jq

# The script is split to three parts, so that your AD admin can create the App Registration separately.
# In that case you need to run each script manually.
# 1) App owner runs script #1
# 2) AD admin runs the script #2 and relays the output json to the app owner
# 3) App owner runs scipt #3 with relevant arguments

# Change these ################################################################

location="westeurope"
resource_group="myapp-rg"

# App name needs to be unique under fomain "azurewebsites.net"
# Make uniq name or use random prefix like here
prefix=$(head /dev/urandom | tr -dc a-z0-9 | head -c 6 ; echo '')
app_name="$prefix-myapp"

###############################################################################

# Deploy the app
./1_az_app_deploy.sh $location $resource_group $app_name

# Create App Registration / Service Principal to AD (needs AD privs)
ad_response=$(./2_az_ad_sp_create.sh $app_name)

# Extract client_id, secret (password) and tenant from the response to be used in the app auth config later.
client_id=$(echo $ad_response | jq -r '.client_id')
password=$(echo $ad_response | jq -r '.password')
tenant=$(echo $ad_response | jq -r '.tenant')

# Configure app authentication
./3_az_app_auth_config.sh $resource_group $app_name $client_id $password $tenant

echo "App url: https://$app_name.azurewebsites.net"
