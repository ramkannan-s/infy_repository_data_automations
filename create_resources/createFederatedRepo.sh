#! /bin/bash

set -o nounset

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"

replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .members.[].url = \"https://psedgeca.jfrog.io/artifactory/$repo_key\" | first(.members.[].url) = \"https://psapac.jfrog.io/artifactory/$repo_key\" | .rclass = \"$repotype\"' repository-template.json"
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
jf rt curl -XPUT "/api/repositories/$repo_key" -d @repository-update-template.json -H 'Content-Type: application/json'