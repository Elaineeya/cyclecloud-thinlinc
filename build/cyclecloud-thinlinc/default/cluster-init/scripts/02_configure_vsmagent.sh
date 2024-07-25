#!/bin/bash

# Fetch the connection mode 
connection_mode=$(jetpack config thinlinc.connection_mode private_ip)

# Determine the agent_hostname based on the connection mode
case "$connection_mode" in
    "private_ip")
        thinlinc_agent_hostname=$(jetpack config cloud.local_ipv4)
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

# Update the agent_hostname
/opt/thinlinc/bin/tl-config /vsmagent/agent_hostname=$thinlinc_agent_hostname
if [[ $? -ne 0 ]]; then
  echo "Failed to configure Thinlinc agent_hostname."
  exit 1
fi

# Restart the vsmagent service to apply changes
systemctl restart vsmagent
if [[ $? -ne 0 ]]; then
  echo "Failed to restart Thinlinc vsmagent service"
  exit 1
fi

echo "Thinlinc agent_hostname configurations completed."
