#!/bin/sh

# Only release currently; running remote config by known developer token
environment="Release"
template_prefix="GoogleService-Info"
source_dir=$(dirname "$PRODUCT_SETTINGS_PATH")
source_plist="$source_dir/$template_prefix-$environment.plist"
destination="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/GoogleService-Info.plist"

if [ -f "$source_plist" ]; then
  echo "Firebase Source: '$source_plist'"
  echo "Firebase Destination: '$destination'"
  cp -v "$source_plist" "$destination"
else
   echo "error: Firebase configuration not found at '$source_plist'"
   exit 1
fi

read_plist_key() {
  local plist_file="$1"
  local key="$2"

  if [ -f "$plist_file" ]; then
    value=$(/usr/libexec/PlistBuddy -c "Print :$key" "$plist_file" 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo "$value"
    else
      echo "error: key not found '$key'."
    fi
  else
    echo "error: file not found $plist_file"
  fi
}

edit_plist() {
  local plist_file="$1"
  local key="$2"
  local value="$3"

  if [ -f "$plist_file" ]; then
    /usr/libexec/PlistBuddy -c "Set :$key $value" "$plist_file"
    if [ $? -eq 0 ]; then
      echo "'$key' updated in '$plist_file'"
    else
      echo "error: update filed for '$key' in '$plist_file'"
    fi
  else
    echo "error: file not found '$plist_file'"
  fi
}

# If secret is empty or unavailable from the CI environment, hydrate from local secrets file
api_key="${GOOGLE_API_KEY:-}"
secrets_plist="${PROJECT_DIR}/BuildScripts/secrets.plist"
if [ -z "$api_key" ] && [ -f "$secrets_plist" ]; then
  api_key=$(read_plist_key "$secrets_plist" "GOOGLE_API_KEY")
elif [ -z "$api_key" ]; then
  echo "warning: missing '$secrets_plist'"
fi

# Hydrate secret in Firebase plist
edit_plist "$destination" "API_KEY" "$api_key"
