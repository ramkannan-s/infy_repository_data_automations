#! /bin/bash

### Exit the script on any failures
set -eo pipefail
set -e
set -u

getList() {
    echo $1
    ./getProjectComponentList.sh $1 $2 $3 $4
    echo -e "" 
}

getDiff() {
    python3 getDiffOfFiles.py -f1 $1 -f2 $2
}

updateDataComponents() {
    echo -e "\n=====> PERFORMING SYNC for $1 <====="
    getList $SOURCE_JPD_URL "source" $1 $SOURCE_AUTH_TOKEN
    getList $DR_1_JPD_URL "jpd1" $1 $DR_1_JPD_AUTH_TOKEN
    getList $DR_2_JPD_URL "jpd2" $1 $DR_2_JPD_AUTH_TOKEN
    while IFS= read -r projectname; do
        echo -e "$1 Difference between Source and JPD1 for $projectname"
        getDiff "$1"_list_"$projectname"_source.txt "$1"_list_"$projectname"_jpd1.txt
        echo "if [ -f list_"$projectname"_sourcelist_"$projectname"_jpd1.txt ]; then"
        if [ -f list_"$projectname"_sourcelist_"$projectname"_jpd1.txt ]; then
            ./updateProjectComponentDiffConfigJPD.sh list_"$projectname"_sourcelist_"$projectname"_jpd1.txt $SOURCE_JPD_URL $DR_1_JPD_URL $SOURCE_AUTH_TOKEN $DR_1_JPD_AUTH_TOKEN $1 $projectname
        else 
            echo "No Diff of Project Found between Source and JPD1 for $projectname !!"
        fi
        echo -e "\n"
        echo -e "$1 Difference between Source and JPD2 for $projectname"
        getDiff "$1"_list_"$projectname"_source.txt "$1"_list_"$projectname"_jpd2.txt
        if [ -f list_"$projectname"_sourcelist_"$projectname"_jpd2.txt ]; then
            ./updateProjectComponentDiffConfigJPD.sh list_"$projectname"_sourcelist_"$projectname"_jpd2.txt $SOURCE_JPD_URL $DR_2_JPD_URL $SOURCE_AUTH_TOKEN $DR_2_JPD_AUTH_TOKEN $1 $projectname
        else 
            echo "No Diff of Project Found between Source and JPD2 for $projectname !!"
        fi
    done < $projectfile
    echo -e "=====> COMPLETED SYNC for $1 <=====\n"
}

### Get Arguments
SOURCE_JPD_URL="${1:?please enter JPD URL. ex - http://35.208.78.203:8082}"
DR_1_JPD_URL="${2:?please enter JPD URL. ex - https://ramkannan.jfrog.io }"
DR_2_JPD_URL="${3:?please enter JPD URL. ex - https://ramkannans.jfrog.io }"
SOURCE_AUTH_TOKEN="${4:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's
DR_1_JPD_AUTH_TOKEN="${5:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's
DR_2_JPD_AUTH_TOKEN="${6:?please provide auth bearer token . ex - access token}"  ### diffes across 3 JPD's

### define variables
projectfile="project-list.txt"

### get list of projects from source JPD
rm -rf *.json
rm -rf *.txt
echo "Get List of Projects from Source JPD = $SOURCE_JPD_URL"
./getProjectList.sh $SOURCE_JPD_URL $SOURCE_AUTH_TOKEN
echo -e ""

### Run the curl API
updateDataComponents "users"
updateDataComponents "groups"
updateDataComponents "roles"

### sample cmd to run - ./getProjectComponentDiffList.sh http://35.208.78.203:8082 https://ramkannan.jfrog.io https://ramkannans-sbx.dev.gcp.devopsacc.team **** **** ****