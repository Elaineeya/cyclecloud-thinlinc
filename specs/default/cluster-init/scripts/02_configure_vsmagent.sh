#!/bin/bash

# Define the path to the configuration file
CONFIG_FILE="/opt/thinlinc/etc/conf.d/vsmagent.hconf"

# Fetch the connection mode 
connection_mode=$(jetpack config thinlinc.connection_mode private_ip)

# Determine the agent_hostname based on the connection mode
case "$connection_mode" in
    "private_ip")
        thinlinc_agent_hostname=""
        ;;
    "public_ip")
        thinlinc_agent_hostname=$(jetpack config cloud.public_ipv4)
        ;;
    "ssh_tunnel")
        thinlinc_agent_hostname="localhost"
        ;;
    *)
        echo "Unknown connection mode: $connection_mode. Exiting script."
        exit 1
        ;;
esac

# Update the /opt/thinlinc/etc/conf.d/vsmagent.hconf file
if [[ -f "$CONFIG_FILE" ]]; then
    sed -i "s/^agent_hostname=.*/agent_hostname=$thinlinc_agent_hostname/" "$CONFIG_FILE"
else
  echo "Configuration file not found: $CONF_FILE"
  exit 1
fi

# Restart the vsmagent service to apply changes
systemctl restart vsmagent
if [[ $? -ne 0 ]]; then
  echo "Failed to restart Thinlinc vsmagent service"
  exit 1
fi

echo "Thinlinc agent_hostname configurations completed."
