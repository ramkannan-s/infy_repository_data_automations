#! /bin/bash

### JFrog hereby grants you a non-exclusive, non-transferable, non-distributable right to use this code solely in connection with your use of a JFrog product or service. This code is provided 'as-is' and without any warranties or conditions, either express or implied including, without limitation, any warranties or conditions of title, non-infringement, merchantability or fitness for a particular cause. Nothing herein shall convey to you any right or title in the code, other than for the limited use right set forth herein. For the purposes hereof "you" shall mean you as an individual as well as the organization on behalf of which you are using the software and the JFrog product or service. 

### Exit the script on any failures
set -eo pipefail
set -e
set -u

getList() {
    echo $1
    curl -XGET -H "Authorization: Bearer ${3}" ${1}/access/api/v1/projects -s | jq 'sort' | jq -r '.[].project_key' > "$projectfile"_"$2"
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

### sample cmd to run - ./getProjectDiffList.sh http://35.208.78.203:8082 https://ramkannan.jfrog.io https://ramkannans-sbx.dev.gcp.devopsacc.team **** **** ****
