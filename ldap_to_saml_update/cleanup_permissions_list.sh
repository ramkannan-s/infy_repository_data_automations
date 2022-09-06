#!/bin/bash

SOURCE_JPD_URL="${1:?please enter JPD URL. ex - https://ramkannans-sbx.dev.gcp.devopsacc.team}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"  ### common credentials across 3 JPD's
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"  ### common credentials across 3 JPD's

permissions_target_list="permissions_target_list.txt"

rm -rf *.txt
rm -rf *.json*

#curl -XGET -u $USER_NAME:$USER_TOKEN $SOURCE_JPD_URL/artifactory/api/security/users -s | jq -rc '.[] | select( .realm == "ldap" ) | .name' > ldap_users.txt

curl -XGET -u $USER_NAME:$USER_TOKEN $SOURCE_JPD_URL/artifactory/api/security/permissions -s | jq -rc '.[] | .name' | grep -v "INTERNAL" | sort | sed 's/ /%20/g' > $permissions_target_list

while IFS= read -r permissions; do
    echo -e "\nGetting JSON for Permission Target ==> $permissions"
    curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/permissions/$permissions" -s > $permissions.json
    curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/permissions/$permissions" -s | jq -rcS .principals.users | jq -r 'keys[]' > "$permissions"_UserList.txt
    if [[ $? != 0 ]]; then
        echo "$permissions" >> perm_delete.txt
    fi
done < $permissions_target_list
