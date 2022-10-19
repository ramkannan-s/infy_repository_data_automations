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
rm -rf *.json

### Run the curl API 

while IFS= read -r username; do
    echo -e "\nFetch yaml for == $username =="
    curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/users/${username}" -s > "$username.json"
    realm=$( curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/users/$username" -s | jq -r '.realm' )
    echo -e "Realm for $username is ==> $realm"
    if [[ "$realm" == *"ldap"* ]]; then
        cmd="cat $username.json | jq ' .name = \"${username}@ad.infosys.com\" ' | jq ' .email = \"${username}@ad.infosys.com\" ' | jq ' .realm = \"saml\" ' > updated_$username.json"
        eval "$cmd" 
        echo -e "uploading yaml for == $username ==\n"
        cat "updated_$username.json"
        curl -XPUT -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/users/${username}@ad.infosys.com" -d @"updated_$username.json" -H 'Content-Type: application/json'
        echo -e "\n"
    else
        echo -e "$username is an $realm user. Hence skipping."
    fi
done < "users-create.txt"

### sample cmd to run - ./usersGroupUpdate.sh http://35.209.109.173:8082 admin ****
