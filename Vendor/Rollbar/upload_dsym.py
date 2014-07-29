# Python script that zips and uploads a dSYM file package to Rollbar during an iOS app's build process.

# Please see the README (https://github.com/rollbar/rollbar-ios/blob/master/README.md) for inscructions in
# setting up this script for your app in Xcode.

import os
import subprocess
import zipfile

if os.environ['DEBUG_INFORMATION_FORMAT'] != 'dwarf-with-dsym' or os.environ['EFFECTIVE_PLATFORM_NAME'] == '-iphonesimulator':
    exit(0)

ACCESS_TOKEN = '928237b9e51e4a03ae600d9ac3c22ee4'
DWARF_DSYM_FOLDER_PATH = os.environ['DWARF_DSYM_FOLDER_PATH']
DWARF_DSYM_FILE_NAME = os.environ['DWARF_DSYM_FILE_NAME']
PRODUCT_SETTINGS_PATH = os.environ['PRODUCT_SETTINGS_PATH']

dsym_file_path = os.path.join(DWARF_DSYM_FOLDER_PATH, DWARF_DSYM_FILE_NAME)
zip_location = '%s.zip' % (dsym_file_path)

os.chdir(DWARF_DSYM_FOLDER_PATH)
with zipfile.ZipFile(zip_location, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for root, dirs, files in os.walk(DWARF_DSYM_FILE_NAME):
        zipf.write(root)

        for f in files:
            zipf.write(os.path.join(root, f))

bundle_process = subprocess.Popen('/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" -c "Print :CFBundleIdentifier" "%s"' % PRODUCT_SETTINGS_PATH,
                     stdout=subprocess.PIPE, shell=True)
stdout, stderr = bundle_process.communicate()
version, identifier = stdout.split()

curl_process = subprocess.Popen('curl -X POST https://api.rollbar.com/api/1/dsym -F access_token=%s -F version=%s -F bundle_identifier="%s" -F dsym=@"%s"'
                     % (ACCESS_TOKEN, version, identifier, zip_location), stdout=subprocess.PIPE, shell=True)
curl_stdout, curl_stderr = curl_process.communicate()

if '"err": 0' not in curl_stdout:
	exit(1)
