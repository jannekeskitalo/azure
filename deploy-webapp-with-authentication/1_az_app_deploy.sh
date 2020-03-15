#!/bin/sh
set -e

location=$1
resource_group=$2
app_name=$3
app_service_plan_name=$resource_group

# Env variables
eventhub_connection_string=foo

az group create --location $location --name $resource_group
az appservice plan create --name $app_service_plan_name --resource-group $resource_group --is-linux --sku F1
az webapp up --sku F1 -n $app_name -l $location --resource-group $resource_group --plan $app_service_plan_name --name $app_name
az webapp config set --resource-group $resource_group --name $app_name --startup-file "python3.7 application.py"
az webapp config appsettings set --resource-group $resource_group --name $app_name --settings EVENTHUB_CONNECTION_STRING=$eventhub_connection_string
az webapp restart --resource-group $resource_group --name $app_name
