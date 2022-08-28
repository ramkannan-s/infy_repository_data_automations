#!/bin/bash

SOURCE_JPD_URL="${1:?please enter JPD URL. ex - https://ramkannans-sbx.dev.gcp.devopsacc.team}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"  ### common credentials across 3 JPD's
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"  ### common credentials across 3 JPD's


while IFS= read -r username; do
    echo -e "\nGenerating yaml for == $username =="
    cmd="cat user.json | jq ' .name = \"${username}\" ' | jq ' .email = \"${username}\" ' > $username.json"
    eval "$cmd" 
    echo -e "uploading yaml for == $username =="
    curl -XPUT -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/users/${username}" -d @"$username.json" -H 'Content-Type: application/json'
done < "saml_users_test.txt"

### sample cmd to run - ./saml_create_users.sh http://35.208.78.203:8082 admin ****