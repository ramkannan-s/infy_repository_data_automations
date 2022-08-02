#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
TARGET_JPD_URL="${2:?please enter JPD URL. ex - https://ramkannan.jfrog.io}"
TYPE="${3:?please enter type of repo. ex - local, remote, virtual, federated, all}"
USER_NAME="${4:?please provide the username in JPD . ex - admin}"
USER_TOKEN="${5:?please provide the user pwd or token or API Key . ex - password}"

getReposJSONList() {
    ./getRepoList.sh "${1}" "${TYPE}" "${USER_NAME}" "${USER_TOKEN}"
    cp "repos_list_${TYPE}.txt" "${2}_repos_list_${TYPE}.txt"
    FILENAME="${2}_repos_list_${TYPE}.txt"
    rm -rf json${2}filespackage ; mkdir json${2}filespackage
    while IFS= read -r reponame; do
        curl -X GET -u "${USER_NAME}":"${USER_TOKEN}" "${1}"/artifactory/api/repositories/"$reponame" -s > "json${2}filespackage/$reponame.json"
    done < $FILENAME
    echo -e "\n"
}

### define variables
rm -rf *.json
rm -rf *.txt

### Get Json from Source JPD
getReposJSONList ${SOURCE_JPD_URL} source

### Get Json from Target JPD
getReposJSONList ${TARGET_JPD_URL} target

### Find the diff of json using python script
./getRepoList.sh "${SOURCE_JPD_URL}" "${TYPE}" "${USER_NAME}" "${USER_TOKEN}"
FILE_NAME="repos_list_${TYPE}.txt"
echo -e "\n"
while IFS= read -r reponame; do
    python3 compareJSONFiles.py -j $reponame
done < $FILE_NAME

if [ -f "repos_to_update.txt" ]; then
    ./updateRepoDiffConfigJPD.sh repos_to_update.txt $SOURCE_JPD_URL $TARGET_JPD_URL $USER_NAME $USER_TOKEN "update"
else 
    echo "No reppositories configuration diff found between Source and Target !!"
fi


### sample cmd to run - ./globalSyncUpdateRepo.sh http://35.208.78.203:8082 https://ramkannan.jfrog.io remote admin ****