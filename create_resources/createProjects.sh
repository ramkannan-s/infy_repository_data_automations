#! /bin/bash

### Get Arguments
projectname="${4:?please enter the project name}"
projectid="${5:?please enter the project count}"
userid="${6:?please enter the username to make as projectadmin}"

project_template_cmd="cat projectTemplate.json | jq '.display_name = \"$projectnameprefix-$item\"' | jq '.project_key = \"$projectidprefix$item\"' > project-$item.json"
eval "$project_template_cmd"
curl -XPOST -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$SOURCE_JPD_URL/access/api/v1/projects" -d @project-"$item".json -s -H 'Content-Type: application/json'
echo -e ""
echo -e "Adding user $userprefix-site-b-user-$item to $projectnameprefix-$item"
user_template_cmd="cat projectUserAdd.json | jq '.name = \"$userprefix-site-b-user-$item\"' > user-$item.json"
eval "$user_template_cmd"
curl -XPUT -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$SOURCE_JPD_URL/access/api/v1/projects/$projectidprefix$item/users/$userprefix-site-b-user-$item" -d @user-$item.json -s -H 'Content-Type: application/json'
