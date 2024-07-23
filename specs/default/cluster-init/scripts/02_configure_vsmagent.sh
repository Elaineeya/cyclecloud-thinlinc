#!/bin/bash

# Fetch the public IP address of the current VM from Azure metadata service
PUBLIC_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2023-07-01&format=text")
# For Standard SKU
#PUBLIC_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/loadbalancer?api-version=2023-07-01" | grep frontendIpAddress | awk  -F'"' '{print $8}')


# Check if the public IP was retrieved successfully
if [ -z "$PUBLIC_IP" ]; then
  #For standard SKU to retrieve the public IP from the load balancer
  PUBLIC_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/loadbalancer?api-version=2023-07-01" | grep frontendIpAddress | awk  -F'"' '{print $8}')
  if  [ -z "$PUBLIC_IP" ]; then
    echo "Failed to retrieve public IP address"
    exit 1
  fi
fi

# Update the /opt/thinlinc/etc/conf.d/vsmagent.hconf file
CONF_FILE="/opt/thinlinc/etc/conf.d/vsmagent.hconf"
if [ -f "$CONF_FILE" ]; then
  sed -i "s/^agent_hostname=.*/agent_hostname=${PUBLIC_IP}/" $CONF_FILE
else
  echo "Configuration file not found: $CONF_FILE"
  exit 1
fi

# Restart the vsmagent service
systemctl restart vsmagent
if [ $? -ne 0 ]; then
  echo "Failed to restart vsmagent service"
  exit 1
fi

echo "vsmagent service restarted successfully with agent_hostname=${PUBLIC_IP}"
echo "Custom configurations completed."
