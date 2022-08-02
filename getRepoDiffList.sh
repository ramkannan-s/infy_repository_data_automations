#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

getList() {
    echo $1
    if [[ $TYPE == "all" ]]; then
        curl -X GET -H 'Content-Type: application/json' -u "${USER_NAME}":"${USER_TOKEN}" "${1}"/artifactory/api/repositories -s | jq -rc '.[] | .key' > "$reposfile"_"$2"
    else
        curl -X GET -H 'Content-Type: application/json' -u "${USER_NAME}":"${USER_TOKEN}" "${1}/artifactory/api/repositories?type=${TYPE}" -s | jq -rc '.[] | .key' > "$reposfile"_"$2"
    fi
    cat "$reposfile"_"$2"
    echo -e "\n"
}

getDiff() {
    python3 getDiffOfFiles.py -f1 $1 -f2 $2
}

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
DR_1_JPD_URL="${2:?please enter JPD URL. ex - https://ramkannan.jfrog.io }"
DR_2_JPD_URL="${3:?please enter JPD URL. ex - https://ramkannans.jfrog.io }"
TYPE="${4:?please enter type of repo. ex - local, remote, virtual, federated, all}"
USER_NAME="${5:?please provide the username in JPD . ex - admin}"  ### common credentials across 3 JPD's
USER_TOKEN="${6:?please provide the user pwd or token or API Key . ex - password}"  ### common credentials across 3 JPD's

### define variables
reposfile="repos-list-${TYPE}"

### Run the curl API 
rm -rf *.json
rm -rf *.txt

getList $SOURCE_JPD_URL "source.txt"
getList $DR_1_JPD_URL "jpd1.txt"
getList $DR_2_JPD_URL "jpd2.txt"

echo -e "Respository Difference between Source and JPD1"
getDiff "$reposfile"_source.txt "$reposfile"_jpd1.txt
echo -e "\n"
echo -e "Respository Difference between Source and JPD2"
getDiff "$reposfile"_source.txt "$reposfile"_jpd2.txt

if [ -f "sourcejpd1.txt" ]; then
    ./updateRepoDiffConfigJPD.sh sourcejpd1.txt $SOURCE_JPD_URL $DR_1_JPD_URL $USER_NAME $USER_TOKEN "create"
else 
    echo "No Diff of repos Found between Source and JPD1 !!"
fi

if [ -f "sourcejpd2.txt" ]; then
    ./updateRepoDiffConfigJPD.sh sourcejpd2.txt $SOURCE_JPD_URL $DR_2_JPD_URL $USER_NAME $USER_TOKEN "create"
else 
    echo "No Diff of repos Found between Source and JPD2 !!"
fi

exit 0

### sample cmd to run - ./getRepoDiffList.sh http://35.208.78.203:8082 https://ramkannan.jfrog.io https://ramkannans-sbx.dev.gcp.devopsacc.team local admin ****