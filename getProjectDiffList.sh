#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

getList() {
    echo $1
    curl -XGET -H "Authorization: Bearer ${3}" ${1}/access/api/v1/projects -s | jq -r '.[].project_key' > "$projectfile"_"$2"
    cat "$projectfile"_"$2"
    echo -e "\n" 
}

getDiff() {
    python3 getDiffOfFiles.py -f1 $1 -f2 $2
}

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
DR_1_JPD_URL="${2:?please enter JPD URL. ex - https://ramkannan.jfrog.io }"
DR_2_JPD_URL="${3:?please enter JPD URL. ex - https://ramkannans.jfrog.io }"
SOURCE_AUTH_TOKEN="${4:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's
DR_1_JPD_AUTH_TOKEN="${5:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's
DR_2_JPD_AUTH_TOKEN="${6:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's

### define variables
projectfile="project-list"

### Run the curl API 
rm -rf *.json
rm -rf *.txt

getList $SOURCE_JPD_URL "source.txt" $SOURCE_AUTH_TOKEN
getList $DR_1_JPD_URL "jpd1.txt" $DR_1_JPD_AUTH_TOKEN
getList $DR_2_JPD_URL "jpd2.txt" $DR_2_JPD_AUTH_TOKEN

echo -e "Project Difference between Source and JPD1"
getDiff "$projectfile"_source.txt "$projectfile"_jpd1.txt
echo -e "\n"
echo -e "Project Difference between Source and JPD2"
getDiff "$projectfile"_source.txt "$projectfile"_jpd2.txt

if [ -f "sourcejpd1.txt" ]; then
    ./updateProjectDiffConfigJPD.sh sourcejpd1.txt $SOURCE_JPD_URL $DR_1_JPD_URL $SOURCE_AUTH_TOKEN $DR_1_JPD_AUTH_TOKEN
else 
    echo "No Diff of projects Found between Source and JPD1 !!"
fi

if [ -f "sourcejpd2.txt" ]; then
    ./updateProjectDiffConfigJPD.sh sourcejpd2.txt $SOURCE_JPD_URL $DR_2_JPD_URL $SOURCE_AUTH_TOKEN $DR_2_JPD_AUTH_TOKEN
else 
    echo "No Diff of projects Found between Source and JPD2 !!"
fi

### sample cmd to run - ./getRepoList.sh https://ramkannans-sbx.dev.gcp.devopsacc.team local admin ****