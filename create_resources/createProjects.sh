#! /bin/bash

### Get Arguments
projectname="${4:?please enter the project name}"
projectid="${5:?please enter the project count}"
userid="${6:?please enter the username to make as projectadmin}"

project_template_cmd="cat projectTemplate.json | jq '.display_name = \"$projectname\"' | jq '.project_key = \"$projectid\"' > project.json"
eval "$project_template_cmd"
curl -XPOST -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$SOURCE_JPD_URL/access/api/v1/projects" -d @project.json -s -H 'Content-Type: application/json'
echo -e ""
echo -e "Adding user $userid to $projectname"
user_template_cmd="cat projectUserAdd.json | jq '.name = \"$userid\"' > user.json"
eval "$user_template_cmd"
curl -XPUT -H "Authorization: Bearer ${JPD_AUTH_TOKEN}" "$SOURCE_JPD_URL/access/api/v1/projects/$projectid/users/$userid" -d @user.json -s -H 'Content-Type: application/json'
