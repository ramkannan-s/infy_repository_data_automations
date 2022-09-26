#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"

### define variables
userlist="users-create.txt"

### Run the curl API 

while IFS= read -r username; do
    echo -e "\nGenerating yaml for == $username =="
    cmd="cat user.json | jq ' .name = \"${username}\" ' | jq ' .email = \"${username}\" ' > $username.json"
    eval "$cmd" 
    echo -e "uploading yaml for == $username =="
    curl -XPUT -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/users/${username}" -d @"$username.json" -H 'Content-Type: application/json'
done < "users-create.txt"

### sample cmd to run - ./usersCreate.sh http://35.208.78.203:8082 admin cmVmdGtuOjAxOjE2OTUzNjk0MDE6YkdIeVFGUnhRWU5ZSmoyQkpYYmlTdnlaeTY4