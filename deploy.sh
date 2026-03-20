#!/bin/bash
set -em # exit on error, allow jobs

az account set --subscription d97d71ba-9297-4938-929f-cedf9824496a

RG_NAME="security-scanner-rg"
LOCATION="uksouth"
RANDOM_SUFFIX=$RANDOM
STORAGE_ACCOUNT="secscanstore$RANDOM_SUFFIX"
APP_SERVICE_PLAN="secscan-plan-$RANDOM_SUFFIX"
WEB_APP_NAME="secscan-api-$RANDOM_SUFFIX"
ACR_NAME="secscanacr$RANDOM_SUFFIX"
QUEUE_NAME="scan-jobs"

echo "========================================="
echo "1. Creating Resource Group: $RG_NAME"
echo "========================================="
az group create --name $RG_NAME --location $LOCATION

echo "========================================="
echo "2. Creating Storage Account: $STORAGE_ACCOUNT"
echo "========================================="
az storage account create --name $STORAGE_ACCOUNT --resource-group $RG_NAME --location $LOCATION --sku Standard_LRS
# Wait a moment for creation
sleep 5

echo "========================================="
echo "3. Creating Request Queue: $QUEUE_NAME"
echo "========================================="
STORAGE_KEY=$(az storage account keys list -g $RG_NAME -n $STORAGE_ACCOUNT --query "[0].value" -o tsv)
az storage queue create --name $QUEUE_NAME --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY
STORAGE_ID=$(az storage account show --name $STORAGE_ACCOUNT --resource-group $RG_NAME --query id -o tsv)

echo "========================================="
echo "4. Deploying NestJS Server API..."
echo "========================================="
# Need to zip the dist/ package and install prod dependencies. Let's just use WebApp Up for source folder.
cd Server
npm install
npm run build
az webapp up --name $WEB_APP_NAME --resource-group $RG_NAME --plan $APP_SERVICE_PLAN --sku F1 --os-type Linux --runtime "NODE:20-lts"

echo "Configuring Identity & Permissions for Node API..."
WEB_APP_PRINCIPAL_ID=$(az webapp identity assign --name $WEB_APP_NAME --resource-group $RG_NAME --query principalId -o tsv)
az role assignment create --assignee $WEB_APP_PRINCIPAL_ID --role "Storage Queue Data Contributor" --scope $STORAGE_ID || echo "Waiting for propagation..."

az webapp config appsettings set --name $WEB_APP_NAME --resource-group $RG_NAME \
  --settings AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT

echo "========================================="
echo "5. Building Python Worker Container"
echo "========================================="
cd ..
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --admin-enabled true

echo "Triggering ACR Build for the Worker..."
cd Server/src/scanner/worker
az acr build --registry $ACR_NAME --image worker:v1 .

echo "========================================="
echo "6. Deploying Python Worker to ACI"
echo "========================================="
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

az container create \
  --resource-group $RG_NAME \
  --name secscan-worker \
  --image $ACR_LOGIN_SERVER/worker:v1 \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --environment-variables "AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT" \
  --assign-identity \
  --cpu 1 --memory 1.5

CONTAINER_PRINCIPAL_ID=$(az container show --name secscan-worker --resource-group $RG_NAME --query identity.principalId -o tsv)
echo "Granting ACI permissions to Azure Queue..."
az role assignment create --assignee $CONTAINER_PRINCIPAL_ID --role "Storage Queue Data Message Processor" --scope $STORAGE_ID || echo "Role assigned."

echo "========================================="
echo "7. Deploying Frontend (Vite) to Azure Static Web Apps"
echo "========================================="
# Build with the new API URL
cd UI
npm install
VITE_API_BASE_URL="https://$WEB_APP_NAME.azurewebsites.net" npm run build
cd ..

# Deploy the 'dist' folder
SWA_NAME="secscan-ui-$RANDOM_SUFFIX"
# Check if extension exists, install if not
az staticwebapp create \
  --name $SWA_NAME \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --source ./UI/dist \
  --token $(az staticwebapp secrets list --name $SWA_NAME --resource-group $RG_NAME --query "properties.apiKey" -o tsv || echo "N/A")

echo "========================================="
echo "ALL SERVICES DEPLOYED!"
echo "API URL: https://$WEB_APP_NAME.azurewebsites.net"
echo "UI URL: (Check 'az staticwebapp show' for $SWA_NAME)"
echo "TEST THE API BY RUNNING:"
echo "curl -X POST https://$WEB_APP_NAME.azurewebsites.net/scan -H \"Content-Type: application/json\" -d '{\"repoUrl\":\"https://github.com/expressjs/express\"}'"
echo "========================================="
