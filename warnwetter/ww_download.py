import requests
import re
import subprocess

WW_URL = "https://warnwetter.en.uptodown.com/android/download"

def download_apk(url, filename):
    response = requests.get(url)
    dl_url = re.findall(r'(?<=href=")https:\/\/dw.uptodown.com.*?(?=")', response.content.decode("utf-8"))[0]
    subprocess.run(["wget", dl_url, "-O", filename])

print("Downloading WarnWetter")
download_apk(WW_URL, "de.dwd.warnapp")
