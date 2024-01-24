#! /bin/bash

set -o nounset

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"
defaultDeploymentRepo="${4:?please enter Default Deployment Repo for Virtual repo}"
repositories="${5:?please enter Repositories List for Virtual repo}"

replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\" | .defaultDeploymentRepo = \"$defaultDeploymentRepo\" | .repositories = \"$repositories\"' repository-template.json"
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
jf rt repo-create repository-update-template.json
