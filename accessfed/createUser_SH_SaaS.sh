#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
TARGET_JPD_URL="${2:?please enter JPD URL. ex - http://35.208.78.203:8082}"
USER_NAME="${3:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${4:?please provide the user pwd or token or API Key . ex - password}"

rm -rf *.txt
rm -rf *.json

userlist="users_saml_internal_list.txt"

### define variables
curl -XGET -u $USER_NAME:$USER_TOKEN "${SOURCE_JPD_URL}/artifactory/api/security/users" -s | jq -rc '.[] | select( .realm == "internal" ) | .name' | sort > $userlist

### Run the curl API 
while IFS= read -r username; do
    echo -e "Download JSON for ====> $username <===="
    curl -XGET -u $USER_NAME:$USER_TOKEN "${SOURCE_JPD_URL}/artifactory/api/security/users/$username?password=true" -s > "$username.json"
    echo -e "\n"
    echo -e "Uploading user ====> $username <==== to ${TARGET_JPD_URL}"
    curl -XPUT -u $USER_NAME:$USER_TOKEN "${TARGET_JPD_URL}/artifactory/api/security/users/$username" -d @"$username.json" -s -H 'Content-Type: application/json'
    echo -e "\n"
done < $userlist

### sample cmd to run - ./createUser_SH_SaaS.sh http://35.209.109.173:8082 http://35.208.222.60:8082 admin ****
