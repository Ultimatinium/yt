#!/bin/bash

echo "Declaring variables"
declare -A artifacts

artifacts["uber-apk-signer.jar"]="patrickfav/uber-apk-signer uber-apk-signer .jar"

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
    rm -f uber-apk-signer.jar
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
[ -d "revanced" ] && mkdir -p revanced/output/release
[ -d "retwitter" ] && mkdir -p retwitter/output/release
[ -d "rereddit" ] && mkdir -p rereddit/output/release

echo "Signing packages"
if [ -f revanced/output/"revanced.apk" ]
then
    echo "Signing ReVanced"
    java -jar uber-apk-signer.jar --allowResign -a revanced/output -o revanced/output/release
elif [ -f retwitter/output/"retwitter.apk" ]
then
    echo "Signing ReTwitter"
    java -jar uber-apk-signer.jar --allowResign -a retwitter/output -o retwitter/output/release
elif [ -f rereddit/output/"rereddit.apk" ]
then
    echo "Signing ReReddit"
    java -jar uber-apk-signer.jar --allowResign -a rereddit/output -o rereddit/output/release
fi

echo "Done signing"
