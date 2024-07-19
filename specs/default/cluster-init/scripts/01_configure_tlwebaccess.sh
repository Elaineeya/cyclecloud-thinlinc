#!/bin/bash

# Define the path to the configuration file
CONFIG_FILE="/opt/thinlinc/etc/conf.d/webaccess.hconf"

# Update the /opt/thinlinc/etc/conf.d/webaccess.hconf file
if [ -f "$CONFIG_FILE" ]; then
    sed -i 's/^listen_port=300$/listen_port=443/' "$CONFIG_FILE"
else
  echo "Configuration file not found: $CONF_FILE"
  exit 1
fi

# Update the listen_port value from default 300 to 443
if ! sed -i 's/^listen_port=300$/listen_port=443/' "$CONFIG_FILE"; then
    echo "Failed to update listen_port in the configuration file."
    exit 1
fi

echo "listen_port updated successfully."

# Restart the tlwebaccess service
systemctl restart tlwebaccess;
if [ $? -ne 0 ]; then
  echo "Failed to restart tlwebaccess service"
  exit 1
fi

echo "tlwebaccess service restarted successfully."
echo "tlwebaccess configurations completed."
