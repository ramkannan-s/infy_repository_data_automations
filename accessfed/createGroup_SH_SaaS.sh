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

grouplist="group_internal_list.txt"

### define variables
curl -XGET -u $USER_NAME:$USER_TOKEN "${SOURCE_JPD_URL}/artifactory/api/security/groups" -s | jq -rc '.[] | select( .realm == "internal" ) | .name' | sort > $grouplist

### Run the curl API 
while IFS= read -r groupname; do
    echo -e "Download JSON for ====> $groupname <===="
    curl -XGET -u $USER_NAME:$USER_TOKEN "${SOURCE_JPD_URL}/artifactory/api/security/groups/$groupname" -s > "$groupname.json"
    echo -e "\n"
    echo -e "Uploading group ====> $groupname <==== to ${TARGET_JPD_URL}"
   # curl -XPUT -u $USER_NAME:$USER_TOKEN "${TARGET_JPD_URL}/artifactory/api/security/groups/$groupname" -d @"$groupname.json" -s -H 'Content-Type: application/json'
    echo -e "\n"
done < $grouplist

### sample cmd to run - ./createGroup_SH_SaaS.sh http://35.209.109.173:8082 http://35.208.222.60:8082 admin ****