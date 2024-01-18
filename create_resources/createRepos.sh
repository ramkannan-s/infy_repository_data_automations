#! /bin/bash

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"

replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-local-template.json"
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
#jf rt repo-delete $repo_key --quiet
jf rt repo-create repo-update-template.json
