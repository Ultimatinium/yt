import requests
import re
import subprocess

YT_MUSIC_URL = "https://youtube-music.en.uptodown.com/android/download"

def download_apk(url, filename):
    response = requests.get(url)
    dl_url = re.findall(r'(?<=href=")https:\/\/dw.uptodown.com.*?(?=")', response.content.decode("utf-8"))[0]
    subprocess.run(["wget", dl_url, "-O", filename])

print("Downloading YouTube Music arm-v7a")
download_apk(YT_MUSIC_URL, "com.google.android.apps.youtube.music.apk")
