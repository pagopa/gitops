#!/bin/bash

set -e

SCRIPT_PATH="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CURRENT_DIRECTORY="$(basename "$SCRIPT_PATH")"
ACTION=$1
GIT_DIFF_STRATEGY=$2
GIT_DIFF_PARAM_ONE=$3
ACTIONS_ALLOWED=("apply" "plan" "changes")

echo "[INFO] This is the current directory: ${CURRENT_DIRECTORY}"

if [ -z "$ACTION" ]; then
  echo "[ERROR] Missed ACTION: apply, plan"
  exit 1
fi

if ! [[ "${ACTIONS_ALLOWED[*]}" =~ ${ACTION} ]]; then
  echo "[ERROR] 🚧 Only this actions are allowed: ${ACTIONS_ALLOWED[*]}"
  exit 1
fi

if [[ ${GIT_DIFF_STRATEGY} == "time" ]]; then
  if [[ -z ${GIT_DIFF_PARAM_ONE} ]]; then
    echo "[ERROR] 🚧 time strategy need a number of days"
    exit 1
  fi

  PROJECTS_CHANGED="$(git diff  --dirstat=files,0 $(git rev-list -n1 --before="${GIT_DIFF_PARAM_ONE} day ago" main) | perl -n -e'/projects\/(.*)/ && print $1' | perl -ple 'chop')"
else
  PROJECTS_CHANGED="$(git diff  --dirstat=files,0 | perl -n -e'/projects\/(.*)/ && print $1' | perl -ple 'chop')"
fi

LIST_PROJECTS_CHANGED="$(echo "$PROJECTS_CHANGED" | tr '/' '\n')"

# shellcheck disable=SC2028
echo "📳 PROJECTS that will be changed: \n${LIST_PROJECTS_CHANGED} \n"
if [[ ${ACTION} == "changes" ]]; then
  exit 0
fi

for dir in ${LIST_PROJECTS_CHANGED}
do
    # shellcheck disable=SC2028
    echo "🟨 started: Terraform $ACTION on ${dir} \n"

    if [[ "${ACTION}" == "apply" ]]; then
      sh terraform.sh "${ACTION}" "${dir}" -auto-approve -compact-warnings
    else
      sh terraform.sh "${ACTION}" "${dir}" -compact-warnings
    fi

    # shellcheck disable=SC2028
    echo "✅ completed: Terraform $ACTION on ${dir} \n"
done
