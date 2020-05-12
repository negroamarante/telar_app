#!/bin/bash

# set perms chmod u+x ./scripts/blitz_setup.sh
# end immediately on non-zero exit codes
set -e

# print message function
printMsg() {
  echo ""
  date +"%T $*"
}

setLoginLink(){
    local arg1=$1
   
    if [[ $arg1 != "" ]];
    then
        content=$(sfdx force:user:display -u $1 --json) 
        result=$( jq -r  '.result' <<< "${content}" ) 
        username=$( jq -r  '.username' <<< "${result}" ) 
        instanceUrl=$( jq -r  '.instanceUrl' <<< "${result}" ) 
        password=$( jq -r  '.password' <<< "${result}" ) 
        loginUrl=$instanceUrl'/?un='$username'&pw='$password
        message='User login link `'$loginUrl'`'

        retval=$message
    else
        echo "No Argument"
    fi
}

# Check for Package Id 
if [ -n "$1" ]; then
    PKG_VER_ID=$1
    printMsg 'Package to be installed ' $PKG_VER_ID
else
   echo 'Package is not set'
   exit 1
fi

ORG_ALIAS=TEST_DEV_PACKAGE
# PKG_VER_ID=04t3k0000027AglAAE

printMsg "Create the Enterprise scratch org $ORG_ALIAS"
#TODO Check DevHub Alias
sfdx force:org:create edition=Enterprise --nonamespace -s -a $ORG_ALIAS -d 15 -f config/project-scratch-def.json 

printMsg "Install the package $PKG_VER_ID"
sfdx force:package:install --package $PKG_VER_ID -u $ORG_ALIAS -w 10

# # TODO: Investigate https://github.com/stomita/sfdx-migration-automatic for data load instead of apex.
# printMsg "Assign SustainabilityAppManager permset to admin user"
# sfdx force:user:permset:assign -n SustainabilityAppManager
# printMsg "Assign SustainabilityCloud permset to admin user"
# sfdx force:user:permset:assign -n SustainabilityCloud

# #Assign the admin user the PSL
# printMsg "Assign the Permission Set License"
# PSL_ID=$(sfdx force:data:soql:query -q "SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'sustain_app_SustainabilityCloudPsl'" -r csv | sed -n 2p)
# ADMIN_ID=$(sfdx force:user:display | grep '^Id' | awk '{print $NF}')

# sfdx force:data:record:create -s PermissionSetLicenseAssign -v "AssigneeId='$ADMIN_ID' PermissionSetLicenseId='$PSL_ID'"

# # DONE WITH THE POSTINSTALLSCRIPT
# printMsg "Load reference and sample Data"
# npm install
# npm run dataLoad

# # push sample profile
# printMsg "Deploy sample profile to blitz org"
# sfdx force:source:deploy -p ./blitz/profiles

# printMsg "Create Users"
# sfdx force:user:create -f config/users/auditor.json -a auditor_$ORG_ALIAS -u $ORG_ALIAS
# sfdx force:user:create -f config/users/app_manager.json -a manager1_$ORG_ALIAS -u $ORG_ALIAS
# sfdx force:user:create -f config/users/app_manager.json -a manager2_$ORG_ALIAS -u $ORG_ALIAS
# sfdx force:user:create -f config/users/app_manager.json -a manager3_$ORG_ALIAS -u $ORG_ALIAS

# printMsg "Assign Permission Set License to manager1_$ORG_ALIAS, manager2_$ORG_ALIAS, manager3_$ORG_ALIAS and auditor_$ORG_ALIAS"
# MANAGER1_ID=$(sfdx force:user:display -u manager1_$ORG_ALIAS | grep '^Id' | awk '{print $NF}')
# MANAGER2_ID=$(sfdx force:user:display -u manager2_$ORG_ALIAS | grep '^Id' | awk '{print $NF}')
# MANAGER3_ID=$(sfdx force:user:display -u manager3_$ORG_ALIAS | grep '^Id' | awk '{print $NF}')
# AUDITOR_ID=$(sfdx force:user:display -u auditor_$ORG_ALIAS | grep '^Id' | awk '{print $NF}')

# sfdx force:data:record:create -s PermissionSetLicenseAssign -v "AssigneeId='$MANAGER1_ID' PermissionSetLicenseId='$PSL_ID'" 
# sfdx force:data:record:create -s PermissionSetLicenseAssign -v "AssigneeId='$MANAGER2_ID' PermissionSetLicenseId='$PSL_ID'" 
# sfdx force:data:record:create -s PermissionSetLicenseAssign -v "AssigneeId='$MANAGER3_ID' PermissionSetLicenseId='$PSL_ID'" 
# sfdx force:data:record:create -s PermissionSetLicenseAssign -v "AssigneeId='$AUDITOR_ID' PermissionSetLicenseId='$PSL_ID'" 

# # # Send credentials to SLACK
# printMsg "Set Users Passwords"
# sfdx force:user:password:generate -o $ORG_ALIAS,auditor_$ORG_ALIAS,manager1_$ORG_ALIAS,manager2_$ORG_ALIAS,manager3_$ORG_ALIAS

# printMsg "Get user details for Login Links"
# setLoginLink $ORG_ALIAS
# CREDENTIALS1='Admin '$retval
# setLoginLink auditor_$ORG_ALIAS
# CREDENTIALS2='Auditor '$retval
# setLoginLink manager1_$ORG_ALIAS 
# CREDENTIALS3='Manager '$retval
# setLoginLink manager2_$ORG_ALIAS
# CREDENTIALS4='Manager '$retval
# setLoginLink manager3_$ORG_ALIAS
# CREDENTIALS5='Manager '$retval

# # Diego
# # SLACK_URL=https://hooks.slack.com/services/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

# # Sustainability channel
# SLACK_URL=https://hooks.slack.com/services/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

# json="{\"blocks\":[{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$CREDENTIALS1\"}},{\"type\":\"divider\"},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$CREDENTIALS2\"}},{\"type\":\"divider\"},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$CREDENTIALS3\"}},{\"type\":\"divider\"},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$CREDENTIALS4\"}},{\"type\":\"divider\"},{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"$CREDENTIALS5\"}}]}"
# curl -X POST ${SLACK_URL} --data-urlencode "payload=$json"