#!/usr/bin/env bash

#
# Setup configuration relative to a given subscription
# Subscription are defined in ./subscription
# Usage:
#  ./setup.sh ENV-CSTAR
#
#  ./setup.sh DEV-CSTAR
#  ./setup.sh UAT-CSTAR
#  ./setup.sh PROD-HUBPA

set -e

SUBSCRIPTION=$1

if [ -z "${SUBSCRIPTION}" ]; then
    printf "\e[1;31mYou must provide a subscription as first argument.\n"
    exit 1
fi

AKS_SUBSCRIPTION="${SUBSCRIPTION}"
KVVAULT_NAME="io-p-kv-azuredevops"
KVVAULT_SUBSCRIPTION="PROD-IO"

SECRET_PREFIX=$(tr [A-Z] [a-z] <<< "${SUBSCRIPTION}")
KVVAULT_SECRETNAME_URL="${SECRET_PREFIX}-aks-apiserver-url"
KVVAULT_SECRETNAME_TOKEN="${SECRET_PREFIX}-aks-azure-devops-sa-token"
KVVAULT_SECRETNAME_CACRT="${SECRET_PREFIX}-aks-azure-devops-sa-cacrt"

az account set -s "${AKS_SUBSCRIPTION}"

aks_private_fqdn=$(az aks list -o tsv --query "[?contains(name,'aks')].{Name:privateFqdn}")
aks_keyvault_name=$(az keyvault list -o tsv --query "[?contains(name,'kv')].{Name:name}")
aks_kayvault_sa_token=$(az keyvault secret show --name aks-azure-devops-sa-token --vault-name "${aks_keyvault_name}" -o tsv --query value)
aks_kayvault_sa_cacrt=$(az keyvault secret show --name aks-azure-devops-sa-cacrt --vault-name "${aks_keyvault_name}" -o tsv --query value)

az account set -s "${KVVAULT_SUBSCRIPTION}"

az keyvault secret set --vault-name "${KVVAULT_NAME}" --name "${KVVAULT_SECRETNAME_URL}" --disabled false --value "https://${aks_private_fqdn}:443"
az keyvault secret set --vault-name "${KVVAULT_NAME}" --name "${KVVAULT_SECRETNAME_TOKEN}" --disabled false --value "${aks_kayvault_sa_token}"
az keyvault secret set --vault-name "${KVVAULT_NAME}" --name "${KVVAULT_SECRETNAME_CACRT}" --disabled false --value "${aks_kayvault_sa_cacrt}"
