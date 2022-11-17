#!/bin/bash

set -euo pipefail

# Updated /etc/passwd with current UID of the running container
grep -v ^deployer /etc/passwd > "/tmp/passwd"
echo "deployer:x:$(id -u):0:deployer user:/home/deployer:/bin/bash" >> /tmp/passwd
cat /tmp/passwd >/etc/passwd
rm /tmp/passwd

# Set a few environment variables
export USER=deployer
export USERNAME=deployer
export HOME=/home/deployer
export PYTHONWARNINGS="ignore:Unverified HTTPS request"

TACKLE2_SVC=${TACKLE2_SVC:-"tackle-ui"}

echo "-------------------------------------------------"
echo "Tackle 2 Setup script"
echo "-------------------------------------------------"
echo "Tackle2 Service:  ${TACKLE2_SVC}"
echo "Tackle2 User:     ${TACKLE2_USER}"
echo "Tackle2 Password: ${TACKLE2_PASSWORD}"
echo "-------------------------------------------------"

# Set no auth flag default
export TACKLE_NOAUTH="--no-auth"

cd $HOME/tackle2-hub/hack/tool

sed -i "s/REPLACE_SVC/${TACKLE2_SVC}/g" ./tackle-config.yml

if [ -n "$TACKLE2_USER" ];
then
  sed -i "s/REPLACE_USER/${TACKLE2_USER}/g" ./tackle-config.yml
  # Clear no auth flag -> use provided user and password to authenticate
  TACKLE_NOAUTH=""
fi

if [ -n "$TACKLE2_PASSWORD" ];
then
  sed -i "s/REPLACE_PASSWORD/${TACKLE2_PASSWORD}/g" ./tackle-config.yml
fi

# Wait until the Tackle2 UI service is available
echo "-------------------------------------------------"
echo "Waiting for Tackle2 UI service to be available..."
echo "-------------------------------------------------"

export CURL_RC=1
while [ "$CURL_RC" != "0" ]
do
  sleep 5
  curl -I http://${TACKLE2_SVC}:8080
  CURL_RC=$?
  echo "  ... not yet (RC: ${CURL_RC})"
done

echo "-------------------------------------------------"
echo "Tackle2 UI service is responding."
echo "-------------------------------------------------"

# Delete all existing Tackle data
echo "-------------------------------------------------"
echo "Cleaning Tackle instance..."
echo "-------------------------------------------------"
export TACKLE_CLEAN_RC=1
while [ "$TACKLE_CLEAN_RC" != "0" ]
do
  ./tackle ${TACKLE_NOAUTH} clean-all
  TACKLE_CLEAN_RC=$?
  if [ "$TACKLE_CLEAN_RC" != "0" ]
  then
    echo "  Cleaning Tackle failed. Sleeping 5s before retrying."
    sleep 5
  fi
done

# Import provided data
echo "-------------------------------------------------"
echo "Importing Tackle data..."
echo "-------------------------------------------------"
export TACKLE_IMPORT_RC=1
while [ "$TACKLE_IMPORT_RC" != "0" ]
do
  ./tackle ${TACKLE_NOAUTH} import
  TACKLE_IMPORT_RC=$?
  if [ "$TACKLE_IMPORT_RC" != "0" ]
  then
    echo "  Importing data into Tackle failed. Sleeping 5s before retrying."
    sleep 5
  fi
done

echo "-------------------------------------------------"
echo "Tackle is ready for demo!"
echo "-------------------------------------------------"
