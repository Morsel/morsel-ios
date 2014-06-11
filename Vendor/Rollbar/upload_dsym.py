"""
Python script that zips and uploads a dSYM file package to Rollbar during an iOS app's build process.

Please see the README (https://github.com/rollbar/rollbar-ios/blob/master/README.md) for inscructions in
setting up this script for your app in Xcode.
"""

import os
import subprocess
import zipfile

ACCESS_TOKEN = '928237b9e51e4a03ae600d9ac3c22ee4'

dsym_file_path = os.path.join(os.environ['DWARF_DSYM_FOLDER_PATH'], os.environ['DWARF_DSYM_FILE_NAME'])
zip_location = '%s.zip' % (dsym_file_path)

os.chdir(os.environ['DWARF_DSYM_FOLDER_PATH'])
with zipfile.ZipFile(zip_location, 'w') as zipf:
    for root, dirs, files in os.walk(os.environ['DWARF_DSYM_FILE_NAME']):
        zipf.write(root)

        for f in files:
            zipf.write(os.path.join(root, f))

p = subprocess.Popen('/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" -c "Print :CFBundleIdentifier" "%s"' % os.environ['PRODUCT_SETTINGS_PATH'],
                     stdout=subprocess.PIPE, shell=True)
stdout, stderr = p.communicate()
version, identifier = stdout.split()

p = subprocess.Popen('curl -X POST https://api.rollbar.com/api/1/dsym -F access_token=%s -F version=%s -F bundle_identifier="%s" -F dsym=@"%s"'
                     % (ACCESS_TOKEN, version, identifier, zip_location), shell=True)
p.communicate()

