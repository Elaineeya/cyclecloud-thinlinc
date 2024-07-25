#!/bin/bash

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
  if ! systemctl disable --now tlwebaccess; then
      echo "Failed to disable tlwebaccess service."
      exit 1
  fi
  echo "Thinlinc tlwebaccess service disable successfully."
}

if [[ "$enable_web" == "True" ]]; then
	# Update the listen_port
	/opt/thinlinc/bin/tl-config /webaccess/listen_port=$thinlinc_web_port
	if [[ $? -ne 0 ]]; then
	  echo "Failed to configure Thinlinc Web Access port number."
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
