#!/bin/bash

echo "Declaring variables"
declare -A apks

apks["com.google.android.apps.youtube.music.apk"]=dl_youtube-music

WGET_HEADER="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0"
ARM_V7A="arm-v7a"
ARM64_V8A="arm64-v8a"

req()
{ wget -nv -O "$2" --header="$WGET_HEADER" "$1"; }

get_apk_vers()
{ req "$1" - | sed -n 's;.*Version:</span><span class="infoSlide-value">\(.*\) </span>.*;\1;p'; }

get_largest_ver()
{
    local max=0
    while read -r v || [ -n "$v" ]
    do
        if [[ ${v//[!0-9]/} -gt ${max//[!0-9]/} ]]
	then max=$v
	fi
    done
    if [[ $max = 0 ]]
    then echo ""
    else echo "$max"
    fi
}

dl_apk()
{
    local url=$1 regexp=$2 output=$3
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n "s/href=\"/@/g; s;.*${regexp}.*;\1;p")"
    echo "$url"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    url="https://www.apkmirror.com$(req "$url" - | tr '\n' ' ' | sed -n 's;.*href="\(.*key=[^"]*\)">.*;\1;p')"
    req "$url" "$output"
}

dl_youtube-music()
{
    local arch=$ARM_V7A
    echo "Downloading YouTube Music (${arch})"
    local last_ver
    last_ver="$version"
    last_ver="${last_ver:-$(get_apk_vers "https://www.apkmirror.com/uploads/?appcategory=youtube-music" | get_largest_ver)}"

    echo "Selected version: ${last_ver}"
    local base_apk="com.google.android.apps.youtube.music.apk"
    if [ ! -f "$base_apk" ]
    then
        if [ "$arch" = "$ARM_V7A" ]
	then
            local regexp_arch='armeabi-v7a</div>[^@]*@\([^"]*\)'
	elif [ "$arch" = "$ARM64_V8A" ]
	then
            local regexp_arch='arm64-v8a</div>[^@]*@\([^"]*\)'
        fi
        declare -r dl_url=$(dl_apk "https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-${last_ver//./-}-release/" \
                "$regexp_arch" \
                "$base_apk")
        echo "YouTube Music (${arch}) v${last_ver}"
        echo "Downloaded from: [YouTube Music (${arch}) - APKMirror]($dl_url)"
    fi
}

for apk in "${!apks[@]}"
do
    if [ ! -f $apk ]
    then
        echo "Downloading $apk"
        version=$(jq -r ".\"$apk\"" <v7a.json)
        ${apks[$apk]}
    fi
done
