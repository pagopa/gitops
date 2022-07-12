#!/bin/bash



#
# bash .utils/terraform_run_all.sh
# bash .utils/terraform_run_all.sh
#

# 'set -e' tells the shell to exit if any of the foreground command fails,
# i.e. exits with a non-zero status.
set -eu

pids=()

array=(
    'azure-devops/projects/sites-projects'
    'azure-devops/projects/sitecorporate-projects'
    'azure-devops/projects/selfcare-projects'
    'azure-devops/projects/selfcare-iac-projects'
    'azure-devops/projects/pagopa-packages-projects'
    'azure-devops/projects/pagopa-packages-frontend-projects'
    'azure-devops/projects/io-tls-cert-projects'
    'azure-devops/projects/io-services-metadata-projects'
    'azure-devops/projects/io-pay-projects'
    'azure-devops/projects/io-iac-projects'
    'azure-devops/projects/io-developer-portal-projects'
    'azure-devops/projects/io-backend-projects'
    'azure-devops/projects/io-app-projects'
    'azure-devops/projects/hub-pa-projects'
    'azure-devops/projects/eucovidcert-projects'
    'azure-devops/projects/devops-projects'
    'azure-devops/projects/cstar-projects'
    'azure-devops/projects/cstar-iac-projects'
    'azure-devops/projects/cgn-onboarding-portal-projects'
    'azure-devops/projects/cert-az-management-projects'
)

function rm_terraform {
    find . \( -iname ".terraform*" ! -iname ".terraform-docs*" ! -iname ".terraform-version" \) -print0 | xargs -0 echo
}

echo "[INFO] 🪚 Delete all .terraform folders"
rm_terraform

echo "[INFO] 🏁 Init all terraform repos"
for index in "${array[@]}" ; do
    FOLDER="${index}"
    pushd "$(pwd)/${FOLDER}"
        echo "🔬 folder: $(pwd)"
        terraform init -upgrade &

        pids+=($!)
    popd
done

# Wait for each specific process to terminate.
# Instead of this loop, a single call to 'wait' would wait for all the jobs
# to terminate, but it would not give us their exit status.
#
for pid in "${pids[@]}"; do
  #
  # Waiting on a specific PID makes the wait command return with the exit
  # status of that process. Because of the 'set -e' setting, any exit status
  # other than zero causes the current shell to terminate with that exit
  # status as well.
  #
  wait "$pid"
done
