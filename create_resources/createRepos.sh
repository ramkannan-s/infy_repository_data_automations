#! /bin/bash

### Get Arguments
repotype="${1:?please enter the repo type. ex - local/remote/virtual/federated}"
packagetype="${2:?please enter the package type type. ex - docker/maven/helm}"
repo_key="${3:?please enter reponame}"

if [ "$repo_key" = "local" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
elif [ "$repo_key" = "remote" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
elif [ "$repo_key" = "virtual" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
elif [ "$repo_key" = "federated" ] ; then
  replace_cmd="jq '.key = \"$repo_key\" | .packageType = \"$packagetype\" | .rclass = \"$repotype\"' repository-template.json"
fi
eval "$replace_cmd" > repository-update-template.json
cat repository-update-template.json
jf rt repo-create repository-update-template.json
