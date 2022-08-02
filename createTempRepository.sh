#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"

### define variables
reposfile="repos_list.txt"
pattern="tmp"

### Run the curl API 
curl -X GET -H 'Content-Type: application/json' -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/repositories -s | jq -rc '.[] | .key' > $reposfile
rm -rf *.json

while read -r reponame; do
    if [[ $reponame != *"-tmp"* ]]; then
        echo -e "Exporting JSON for $reponame as $reponame.json file."
        curl -X GET -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/repositories/"$reponame" -s > "$reponame.json"
        jq --arg a "$reponame-$pattern" '.key = $a' "$reponame.json" > test.json && mv test.json "$reponame.json"
        curl -X PUT -u "${USER_NAME}":"${USER_TOKEN}" "$SOURCE_JPD_URL"/artifactory/api/repositories/"$reponame"-tmp -d @"$reponame.json" -s -H 'Content-Type: application/json'
        echo -e "\n"
    else
        echo -e "Pattern already exist for $reponame.. SKIPPING\n"
    fi
done <$reposfile

### sample cmd to run - ./createTempRepository.sh https://ramkannans-sbx.dev.gcp.devopsacc.team admin ****