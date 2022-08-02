#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
FILE_NAME="${1:?please provide the file name to parse. ex - diffFile.txt}"
SOURCE_JPD_URL="${2:?please enter JPD URL. ex - http://35.208.78.203:8082}"
TARGET_JPD_URL="${3:?please enter JPD URL. ex - https://ramkannan.jfrog.io}"
SOURCE_AUTH_TOKEN="${4:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's
JPD_AUTH_TOKEN="${5:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's

rm -rf *.json

### parse file
while IFS= read -r line; do
    if [[ $line == *"+"* ]]; then
        projectadd=$(echo $line | cut -d "+" -f2 | xargs)
        echo -e "\nAdd Project ==> $projectadd"
        echo -e "Exporting JSON for $projectadd from $SOURCE_JPD_URL"
        curl -XGET -H "Authorization: Bearer ${SOURCE_AUTH_TOKEN}" "$SOURCE_JPD_URL"/access/api/v1/projects/"$projectadd" -s > "$projectadd.json"
        echo -e "Importing JSON $projectadd.json to $TARGET_JPD_URL"
        curl -XPOST -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$TARGET_JPD_URL"/access/api/v1/projects -d @"$projectadd".json -s -H 'Content-Type: application/json'
        echo -e "\n"
    elif [[ $line == *"-"* ]]; then
        projectdelete=$(echo $line | cut -d "-" -f2- | xargs)
        echo -e "\nDelete Repo ==> $projectdelete"
        curl -XDELETE -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$TARGET_JPD_URL"/access/api/v1/projects/"$projectdelete"
    else 
        echo -e "\nInvalid Input"
    fi
done < $FILE_NAME

exit 1

### sample cmd to run - ./createTempRepository.sh https://ramkannans-sbx.dev.gcp.devopsacc.team admin ****