#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
FILE_NAME="${1:?please provide the file name to parse. ex - diffFile.txt}"
SOURCE_JPD_URL="${2:?please enter JPD URL. ex - http://35.208.78.203:8082}"
TARGET_JPD_URL="${3:?please enter JPD URL. ex - https://ramkannan.jfrog.io}"
USER_NAME="${4:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${5:?please provide the user pwd or token or API Key . ex - password}"
METHOD="${6:?please provide method to perform . ex - PUT to create or POST for update}"

rm -rf *.json

### parse file
while IFS= read -r line; do
    if [[ $line == *"+"* ]]; then
        repoadd=$(echo $line | cut -d "+" -f2 | xargs)
        echo -e "\nAdd Repo ==> $repoadd"
        echo -e "Exporting JSON for $repoadd from $SOURCE_JPD_URL"
        curl -X GET -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/repositories/"$repoadd" -s > "$repoadd.json"
        echo -e "Importing JSON $repoadd.json to $TARGET_JPD_URL"
        if [[ $METHOD == "create" ]]; then
            curl -X PUT -u "${USER_NAME}":"${USER_TOKEN}" "$TARGET_JPD_URL"/artifactory/api/repositories/"$repoadd" -d @"$repoadd.json" -s -H 'Content-Type: application/json'
        elif [[ $METHOD == "update" ]]; then
            curl -X POST -u "${USER_NAME}":"${USER_TOKEN}" "$TARGET_JPD_URL"/artifactory/api/repositories/"$repoadd" -d @"$repoadd.json" -s -H 'Content-Type: application/json'
        else 
            echo -e "\nInvalid Method given in arguments"
        fi
        echo -e "\n"
    elif [[ $line == *"-"* ]]; then
        repodelete=$(echo $line | cut -d "-" -f2- | xargs)
        echo -e "\nDelete Repo ==> $repodelete"
        curl -X DELETE -u "${USER_NAME}":"${USER_TOKEN}" "$TARGET_JPD_URL"/artifactory/api/repositories/"$repodelete"
    else 
        echo -e "\nInvalid Input"
    fi
done < $FILE_NAME

### sample cmd to run - ./createTempRepository.sh https://ramkannans-sbx.dev.gcp.devopsacc.team admin ****