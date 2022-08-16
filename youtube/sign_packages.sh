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
[ -d "youtube" ] && mkdir -p youtube/output/release
[ -d "twitter" ] && mkdir -p twitter/output/release
[ -d "reddit" ] && mkdir -p reddit/output/release
[ -d "tiktok" ] && mkdir -p tiktok/output/release

echo "Signing packages"
if [ -f youtube/output/"youtube.apk" ]
then
    echo "Signing YouTube"
    java -jar uber-apk-signer.jar --allowResign -a youtube/output -o youtube/output/release
elif [ -f twitter/output/"twitter.apk" ]
then
    echo "Signing Twitter"
    java -jar uber-apk-signer.jar --allowResign -a twitter/output -o twitter/output/release
elif [ -f reddit/output/"reddit.apk" ]
then
    echo "Signing Reddit"
    java -jar uber-apk-signer.jar --allowResign -a reddit/output -o reddit/output/release
elif [ -f tiktok/output/"tiktok.apk" ]
then
    echo "Signing TikTok"
    java -jar uber-apk-signer.jar --allowResign -a tiktok/output -o tiktok/output/release
fi

echo "Done signing"
