#!/bin/bash

echo "Declaring variables"
declare -A artifacts

artifacts["revanced-cli.jar"]="revanced/revanced-cli revanced-cli .jar"
artifacts["revanced-patches.jar"]="revanced/revanced-patches revanced-patches .jar"

get_artifact_download_url()
{
    local api_url result
    api_url="https://api.github.com/repos/$1/releases/latest"
    result=$(curl -s $api_url | jq ".assets[] | select(.name | contains(\"$2\") and contains(\"$3\") and (contains(\".sig\") | not)) | .browser_download_url")
    echo "${result:1:-1}"
}

echo "Cleaning up"
if [[ "$1" == "clean" ]]
    then
    rm -f revanced-cli.jar revanced-patches.jar
    exit
fi

echo "Fetching dependencies"
for artifact in "${!artifacts[@]}"
do
    if [ ! -f "$artifact" ]
    then
        echo "Downloading $artifact"
        curl -sLo "$artifact" $(get_artifact_download_url ${artifacts[$artifact]})
    fi
done

echo "Preparing"
mkdir -p output

echo "Compiling WarnWetter"
if [ -f "de.dwd.warnapp.apk" ]
then
    echo "Compiling package"
    java -jar revanced-cli.jar -b revanced-patches.jar -r \
                               -i promo-code-unlock \
                               -a de.dwd.warnapp.apk -o output/de.dwd.warnapp.apk
else
    echo "Cannot find WarnWetter base package, skip compiling"
fi

echo "Done compiling"