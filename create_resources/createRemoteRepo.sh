#! /bin/bash

set -o nounset

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"
url="${4:?please enter URL for Remote repo}"
username=${5:-''}
password=${6:-''}

if [ -z "$username" ]; then
    replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .url = \"$url\" | del(.username) | del(.password) | del(.members)' repository-template.json"
else 
    replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .url = \"$url\" | .username = \"$username\" | .password = \"$password\" | del(.members)' repository-template.json"
fi
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
jf rt repo-create repository-update-template.json
