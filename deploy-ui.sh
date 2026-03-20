#!/bin/bash
set -e

# Configuration (Defaults or taken from current session)
RG_NAME="security-scanner-rg"
LOCATION="uksouth"
SWA_NAME="secscan-ui-$RANDOM"

# 1. Build the production bundle
echo "Building UI for production..."
cd UI
# Ideally, you'd get this from the Azure Web App deployment output
# But let's assume the user knows it or we can find it.
# For now, let's just build it.
npm install
npm run build
cd ..

# 2. Deploy to Azure Static Web Apps
echo "Deploying to Azure Static Web Apps..."
# This command requires the 'staticwebapp' extension
az staticwebapp create \
  --name $SWA_NAME \
  --resource-group $RG_NAME \
  --location $LOCATION \
  --source ./UI/dist \
  --token $(az staticwebapp secrets list --name $SWA_NAME --resource-group $RG_NAME --query "properties.apiKey" -o tsv || echo "N/A")

echo "========================================="
echo "UI DEPLOYMENT STARTED!"
echo "Check your SWA URL in the Azure Portal or via 'az staticwebapp show --name $SWA_NAME'"
echo "========================================="
