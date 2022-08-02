#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
TYPE="${2:?please enter type of repo. ex - local, remote, virtual, federated, all}"
USER_NAME="${3:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${4:?please provide the user pwd or token or API Key . ex - password}"

### define variables
reposfile="repos_list_${TYPE}.txt"

### Run the curl API 
rm -rf *.json
rm -rf *.txt

if [[ $TYPE == "all" ]]; then
    curl -X GET -H 'Content-Type: application/json' -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/repositories -s | jq -rc '.[] | .key' > $reposfile
else
    curl -X GET -H 'Content-Type: application/json' -u "${USER_NAME}":"${USER_TOKEN}" "${SOURCE_JPD_URL}/artifactory/api/repositories?type=${TYPE}" -s | jq -rc '.[] | .key' > $reposfile
fi
cat repos_list_${TYPE}.txt

### sample cmd to run - ./getRepoList.sh https://ramkannans-sbx.dev.gcp.devopsacc.team local admin ****