#!/bin/bash

# Define the path to the configuration file
CONFIG_FILE="/opt/thinlinc/etc/conf.d/webaccess.hconf"

# Fetch thinlinc web access parameters
enable_web=$(jetpack config thinlinc.enable_web False)
thinlinc_web_port=$(jetpack config thinlinc.web_port 443)

# Update the /opt/thinlinc/etc/conf.d/webaccess.hconf file
if [[ "$enable_web" == "True" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
      sed -i "s/^listen_port=.*/listen_port=$thinlinc_web_port/" $CONFIG_FILE
    else
      echo "Configuration file not found: $CONFIG_FILE"
      exit 1
    fi
else
    echo "Web access is not enabled. Exiting script."
    exit 0
fi

# Restart the tlwebaccess service
systemctl restart tlwebaccess;
if [[ $? -ne 0 ]]; then
  echo "Failed to restart Thinlinc tlwebaccess service"
  exit 1
fi

echo "Thinlinc Web Access port number configurations completed."
