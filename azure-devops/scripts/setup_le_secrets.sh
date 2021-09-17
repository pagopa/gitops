#!/usr/bin/env bash

KVVAULT_NAME="io-p-kv-azuredevops"
KVVAULT_SUBSCRIPTION="PROD-IO"

az account set -s "${KVVAULT_SUBSCRIPTION}"

az keyvault secret set --vault-name "${KVVAULT_NAME}" --name "le-private-key-json" --subscription "${KVVAULT_SUBSCRIPTION}" --disabled false --file le_private_key.json
az keyvault secret set --vault-name "${KVVAULT_NAME}" --name "le-regr-json" --subscription "${KVVAULT_SUBSCRIPTION}" --disabled false --file le_regr.json
