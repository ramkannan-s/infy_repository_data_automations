#! /bin/bash

set -o nounset

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"
defaultDeploymentRepo="${4:?please enter Default Deployment Repo for Virtual repo}"
repositories="${5:?please enter Repositories List for Virtual repo}"

repositories_arry_string=""
IFS=","
for repo in $repositories; do
    repositories_arry_string+="\"$repo\", "
done
repositories_data=$(echo "[ $repositories_arry_string" | rev | cut -c3- | rev )]
echo "$repositories_data"

replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .defaultDeploymentRepo = \"$defaultDeploymentRepo\" | del(.members) | .repositories = $repositories_data' repository-template.json"
eval "$replace_cmd" > repository-update-template.json
sed -i -e 's/\\//g' repository-update-template.json
cat repository-update-template.json
jf rt curl -XPUT "/api/repositories/$repo_key" -d @repository-update-template.json -H 'Content-Type: application/json'
