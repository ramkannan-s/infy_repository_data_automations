#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - https://35.208.78.203:8082}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"

### define variables
FILE_NAME="perm_delete.txt"

### Run the curl API reading from file
while IFS= read -r permdelete; do
    echo -e "\nDelete Repo ==> $permdelete"
    curl -X DELETE -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/security/permissions/"$permdelete"
done < $FILE_NAME

### sample cmd to run - ./reposDelete.sh https://35.208.78.203:8082 admin ****