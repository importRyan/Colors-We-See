#!/bin/sh
#set -e

# Remove dyld metadata that bloats app size, but is already archived to Crashlytics
# https://docs.emergetools.com/docs/strip-binary-symbols
# https://www.emergetools.com/blog/posts/how-xcode14-unintentionally-increases-app-size
function stripExecutable {
  if [ -f "$1" ]
  then
    strip -rSTx -no_code_signature_warning "$1"
    echo "Stripped: " "$1"
  else
    echo "error: Missing:" "$1"
    exit 2
  fi
}

function stripFrameworks {
  if [ -d "$1" ]
  then
    find "$1" -type f -mindepth 2 -maxdepth 2 -not -name "*.*" -exec sh -c 'chmod a+w "{}" || echo "Write permission override failed: {}"' \;
    find "$1" -type f -mindepth 2 -maxdepth 2 -not -name "*.*" -exec sh -c 'codesign -v -R="anchor apple" "{}" &> /dev/null && echo "Skipped Apple framework: {}" || (strip -rSTx -no_code_signature_warning "{}" && echo "Stripped: {}")' \;
  else
    echo "error: Missing frameworks directory:" "$1"
    exit 2
  fi
}

if [[ ${CI} || "${CONFIGURATION}" == "Release" ]]
then
  stripExecutable "${CODESIGNING_FOLDER_PATH}/${PRODUCT_NAME}"
  stripFrameworks "${CODESIGNING_FOLDER_PATH}/Frameworks"
else
  echo "Local debug build. Did not remove dyld metadata"
fi
