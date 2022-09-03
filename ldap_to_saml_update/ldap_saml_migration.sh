#!/bin/bash

SOURCE_JPD_URL="${1:?please enter JPD URL. ex - https://ramkannans-sbx.dev.gcp.devopsacc.team}"
USER_NAME="${2:?please provide the username in JPD . ex - admin}"  ### common credentials across 3 JPD's
USER_TOKEN="${3:?please provide the user pwd or token or API Key . ex - password}"  ### common credentials across 3 JPD's

permissions_target_list="permissions_target_list.txt"

rm -rf *.txt
rm -rf *.json*
rm -rf sed_list.sh

#curl -XGET -u $USER_NAME:$USER_TOKEN $SOURCE_JPD_URL/artifactory/api/security/users -s | jq -rc '.[] | select( .realm == "ldap" ) | .name' > ldap_users.txt

curl -XGET -u $USER_NAME:$USER_TOKEN $SOURCE_JPD_URL/artifactory/api/security/permissions -s | jq -rc '.[] | .name' | grep -v "INTERNAL" | sort | sed 's/ /%20/g' > $permissions_target_list

while IFS= read -r permissions; do
    echo -e "\nGetting JSON for Permission Target ==> $permissions"
    if [[ "$permissions" == *"("* ]]; then
        permfilename=$( echo "$permissions" | sed 's/(/\_/g' | sed 's/)//g' )
    else 
        permfilename=$permissions
    fi
    curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/permissions/$permissions" -s > $permfilename.json
    curl -XGET -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/permissions/$permissions" -s | jq -rcS .principals.users | jq -r 'keys[]' > "$permfilename"_UserList.txt
    if [[ "$permissions" != *"Any%20Remote"* || "$permissions" != *"Anything"* ]]; then
        while IFS= read -r user; do
            if [[ "$user" == *"anonymous"* ]]; then
                echo "Skip for $user"
            elif [[ "$user" == *"admin"* ]]; then
                echo "Skip for $user"
            elif [[ "$user" == *"@ad.infosys.com"* ]]; then
                echo "Skip for $user"
            else 
                echo -e "Updating for $user in $permfilename.json"
                echo -e "sed -i -e 's/$user/$user\@ad.infosys.com/g' $permfilename.json" >> sed_list.sh
                echo -e ""
            fi
        done < "$permfilename"_UserList.txt
    fi
done < $permissions_target_list


chmod +x sed_list.sh
./sed_list.sh

while IFS= read -r permissions; do
    if [[ "$permissions" == *"("* ]]; then
        permfilename=$( echo "$permissions" | sed 's/(/\_/g' | sed 's/)//g' )
        echo -e "\nFilename===> $permfilename"
    else 
        permfilename=$permissions
        echo -e "\nFilename===> $permfilename"
    fi
    echo -e "Uploading JSON for filename $permfilename.json"
    #curl -XPUT -u $USER_NAME:$USER_TOKEN "$SOURCE_JPD_URL/artifactory/api/security/permissions/$permissions" -s -d @$permfilename.json -H "Content-Type: application/json"
done < $permissions_target_list