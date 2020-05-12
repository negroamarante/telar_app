#!/bin/bash

# This script will create a new Beta version for the sustain_app_dev package.
# Considering the Last Release version as ancestor
# Using the branch that where the Engineer has develop

# print message function
printMsg() {
  echo ""
  date +"%T $*"
}

existJQ(){
    if ! [ -x "$(command -v jq)" ]; 
    then
        echo 'jq is not installed.' >&2
        if ! [ -x "$(command -v brew)" ]; 
        then
            brew install jq
        else
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
            brew install jq
        fi
    else 
        echo 'jq is installed.' >&2
    fi
}

getDevHubUsername(){
    # If the username has the 'sustainapp.devhub' then it is the devhub
    for row in $(sfdx force:org:list --json | jq -r  '.result.nonScratchOrgs[] | .username') ; do
        if [[ $row == *"sustainapp.devhub"* ]]; then
            retval=${row}
        fi
    done
}

# getDevHubUsername
DEV_HUV=personalDevHub
PACKAGE_NS=test2GP_dev

printMsg "Check if jq is installed" 
existJQ

# targetdevhubusername
printMsg "Get DevHub username" $DEV_HUV

# Get branch
BRANCH=$(git name-rev --name-only HEAD)
printMsg "Branch" $BRANCH

printMsg "Get Ancestor Id "
# 	Ancestor Id
#       Always has to be a previous version, and it cannot be a patch. Only patch versions can have a patch ancestor
# 		Example:
# 			versions available 0.1.0.0 y 0.1.1.1
# 			For version 0.2.1.0, ancestor must be 0.1.0.0

# Get list of all package versions
package=$(sfdx force:package:version:list -p $PACKAGE_NS  --orderby MajorVersion,MinorVersion,PatchVersion,BuildNumber --json)
length=$(echo $package | jq ' .result | length')
content=$(echo  $package | jq '.result['$(($length-1))']')
isReleased=$( jq -r  '.IsReleased' <<< "${content}" ) 
# If last build is a release
if $isReleased
then
    # Get AncestorId from SubscriberPackageVersionId and Version should increase a minor
    ancestorId=$( jq -r  '.SubscriberPackageVersionId' <<< "${content}" ) 
else
    # Get AncestorId from ancestorId and Version should increase a build
    ancestorId=$( jq -r  '.AncestorId' <<< "${content}" ) 
fi

# Calculate new version number
# 		--versionnumber
version=$( jq -r  '.Version' <<< "${content}" )
regex="([0-9]+).([0-9]+).([0-9]+).([0-9]+)"
if [[ $version =~ $regex ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  build="${BASH_REMATCH[4]}"
fi

if $isReleased
then
    # Version should increase on minor, build 0 for freash start
    minor=$(echo $minor + 1 | bc)
    build=0
else
    # Version should increase on build
    build=$(echo $build + 1 | bc)
fi
nextVersion=${major}.${minor}.${patch}.${build}
versionName=$nextVersion
printMsg 'Next Version to build' $nextVersion ' and version name' $versionName

printMsg 'Update sfdx-project with ancestor Id'
jq '.packageDirectories[1] |= . + {"ancestorId": "'$ancestorId'"}' sfdx-project.json > aux.json
cp aux.json sfdx-project.json

# 	Create the new version
sfdx force:package:version:create --package "$PACKAGE_NS" --versionnumber $nextVersion --branch "$BRANCH" --postinstallscript=PostInstallScript --codecoverage  --installationkeybypass --wait 20 --json
# newPackage=$(sfdx force:package:version:create --package "$PACKAGE_NS" --versionnumber $nextVersion --branch "$BRANCH" --postinstallscript=PostInstallScript --codecoverage  --installationkeybypass --wait 20 --json)
# Example result
# {
#     "status": 0,
#     "result": {
#         "Id": "08c3i000000CbDXAA0",
#         "Status": "Success",
#         "Package2Id": "0Ho3i000000CadnCAC",
#         "Package2VersionId": "05i3i000000CafTAAS",
#         "SubscriberPackageVersionId": "04t3i000002Sa1EAAS",
#         "Tag": null,
#         "Branch": "testCICD",
#         "Error": [],
#         "CreatedDate": "2020-04-29 14:35"
#     }
# }

packageId=$(echo $newPackage | jq -r '.result.SubscriberPackageVersionId')

# printMsg 'Blitz org for new package'
# sh blitz.sh $packageId