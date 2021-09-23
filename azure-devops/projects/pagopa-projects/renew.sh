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

SP_SUBSCRIPTION="${SUBSCRIPTION}"
KVVAULT_NAME="io-p-kv-azuredevops"
KVVAULT_SUBSCRIPTION="PROD-IO"

az keyvault secret list --vault-name "${KVVAULT_NAME}" --subscription "${KVVAULT_SUBSCRIPTION}" -o tsv --query "[?contains(name,'-platform-pagopa-it')].{Name:name}" # -o tsv --query value

echo "ok"

az keyvault secret list --vault-name "${KVVAULT_NAME}" --subscription "${KVVAULT_SUBSCRIPTION}" -o tsv --query "[?contains(name,'azdo-sp-pagopa-')].{Name:name}" # -o tsv --query value
