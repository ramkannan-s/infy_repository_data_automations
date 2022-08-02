#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
AUTH_TOKEN="${2:?please provide auth bearer token . ex - access token}"

### define variables
reposfile="project_list.txt"

### Run the curl API 
rm -rf *.json
rm -rf *.txt

curl -XGET -H "Authorization: Bearer ${AUTH_TOKEN}" ${SOURCE_JPD_URL}/access/api/v1/projects -s | jq -r '.[].project_key' > $reposfile
cat $reposfile

### sample cmd to run - ./getProjectList.sh https://ramkannans-sbx.dev.gcp.devopsacc.team ****