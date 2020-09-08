############################ #
# Dette scriptet må enten kjøres fra en datamaskin hvor du har rettigheter til å
# installere Azure CLI eller fra Azures Cloud Shell (https://shell.azure.com/).
# Scriptet vil automatisk bruke din VS-subscription om dette har "Visual Studio" i navnet
#
# Scriptet oppretter:
# - En resource group som holder alle ressursene
# - En Azure Data Lake
# - En Storage-konto med tilhørende container (Husk å gi STORAGE_ACCOUNT_NAME et unikt navn)
# - Et Azure Databricks workspace
# - En Service Principal som har Storage Blob Contributor tilgang til din storage account
# For å slette ressursgruppen: 
# Kjør: az group delete --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION
# 
############################# #

#!/bin/bash
set -e

# Remove variables.txt if it exists
if [ -f variables.txt ] ; then
    rm variables.txt
fi

# Find variables defined before execution of the script and store them in a temporary file
( set -o posix ; set ) >/tmp/variables.before

# Define function to store variables defined in script
function script_variables()
{
# Find variables defined before execution of the script and in the script and store them in a temporary file
( set -o posix ; set ) >/tmp/variables.after

# Find variables defined only in script and write to variables.txt
diff /tmp/variables.before /tmp/variables.after > variables.txt

# Delete unwanted rows from variables.txt and clean output
sed -i '/^\(>\)/!d' variables.txt
sed -i 's/^..//' variables.txt
}

# Install Azure CLI (Linux-versjon)
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 

# Login (open in IE hvis du har problemer i Chrome)
#az login

### Input parameters
#Project name should be only alphanumeric characters
echo "Input your desired project name. All characters must be alphanumeric:"
read -p "Project name: " PROJECT_NAME

while [[ "$PROJECT_NAME" =~ [^a-zA-Z0-9] ]]
  do
    echo "Invalid project name. Remember that all characters must be alphanumeric"
    echo "Input your desired project name:"
    read -p "Project name: " PROJECT_NAME
  done

read -p "Resource location: " RESOURCE_LOCATION

RESOURCE_GROUP=rg-$PROJECT_NAME
DATABRICKS_WORKSPACE=dbw-$PROJECT_NAME

az group create \
  --name $RESOURCE_GROUP \
  --location $RESOURCE_LOCATION 

az databricks workspace create --location $RESOURCE_LOCATION\
                               --name $DATABRICKS_WORKSPACE\
                               --resource-group $RESOURCE_GROUP\
                               --sku "trial"
