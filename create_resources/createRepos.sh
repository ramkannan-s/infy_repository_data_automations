#! /bin/bash

set -o nounset

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"
url="${4:?please enter URL for Remote repo}"
username="${5:?please enter username for Remote repo}"
password="${6:?please enter password for Remote repo}"
defaultDeploymentRepo="${7:?please enter Default Deployment Repo for Virtual repo}"
repositories="${8:?please enter Repositories List for Virtual repo}"

if [ "$repo_key" = "local" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
elif [ "$repo_key" = "remote" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .url = \"$url\" | .username = \"$username\" | .password = \"$password\"' repository-template.json"
elif [ "$repo_key" = "virtual" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .defaultDeploymentRepo = \"$defaultDeploymentRepo\" | .repositories = \"$repositories\"' repository-template.json"
elif [ "$repo_key" = "federated" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
fi
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
jf rt repo-create repository-update-template.json
