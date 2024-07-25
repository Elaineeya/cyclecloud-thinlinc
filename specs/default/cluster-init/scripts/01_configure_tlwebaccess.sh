#!/bin/bash

# Define the path to the configuration file
CONFIG_FILE="/opt/thinlinc/etc/conf.d/webaccess.hconf"

# Fetch thinlinc web access parameters
enable_web=$(jetpack config thinlinc.enable_web False)
thinlinc_web_port=$(jetpack config thinlinc.web_port 443)

# Function to restart tlwebaccess service
restart_tlwebaccess() {
    if ! systemctl restart tlwebaccess; then
        echo "Failed to restart tlwebaccess service."
        exit 1
    fi
    echo "Thinlinc tlwebaccess service restarted successfully."
}

# Function to disable tlwebaccess service
disable_tlwebaccess() {
    if ! systemctl stop tlwebaccess; then
        echo "Failed to stop tlwebaccess service."
        exit 1
    fi
    echo "Thinlinc tlwebaccess service stopped successfully."
}

# Update the /opt/thinlinc/etc/conf.d/webaccess.hconf file
if [[ "$enable_web" == "True" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
      sed -i "s/^listen_port=.*/listen_port=$thinlinc_web_port/" $CONFIG_FILE
    else
      echo "Configuration file not found: $CONFIG_FILE"
      exit 1
    fi
    # Restart the tlwebaccess service to apply changes
    restart_tlwebaccess
    echo "Thinlinc Web Access port number configurations completed."
else
    # Disable the tlwebaccess service
    disable_tlwebaccess
    echo "Disable Thinlinc Web access completed."
fi
