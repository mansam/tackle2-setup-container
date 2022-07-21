#!/bin/bash

# Updated /etc/passwd with current UID of the running container
grep -v ^deployer /etc/passwd > "/tmp/passwd"
echo "deployer:x:$(id -u):0:deployer user:/home/deployer:/bin/bash" >> /tmp/passwd
cat /tmp/passwd >/etc/passwd
rm /tmp/passwd

# Set a few environment variables
export USER=deployer
export USERNAME=deployer
export HOME=/home/deployer

echo "------------------------------------------------"
echo "Tackle 2 Setup script"
echo "------------------------------------------------"
echo "Tackle2 User:     ${TACKLE2_USER}"
echo "Tackle2 Password: ${TACKLE2_PASSWORD}"
echo "------------------------------------------------"

# Set no auth flag default
export TACKLE_NOAUTH="--no-auth"

cd $HOME/tackle2-hub/hack/tool

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
echo "Waiting for Tackle2 UI service to be available..."

export CURL_RC=1
while [ "$CURL_RC" != "0" ]
do
  sleep 5
  curl -sI http://tackle-ui:8080 -o /dev/null
  CURL_RC=$?
  echo "  ... not yet (RC: ${CURL_RC})"
done

echo "Tackle2 UI service is responding."
echo "Time to configure Tackle2..."
echo "------------------------------------------------"

# Clean all Tackle data
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
echo "Cleaning Tackle instance..."
echo "------------------------------------------------"
./tackle ${TACKLE_NOAUTH} clean-all

# Import provided data
echo "Importing Tackle data..."
echo "------------------------------------------------"
./tackle ${TACKLE_NOAUTH} import

echo "------------------------------------------------"
echo "Tackle is ready for demo!"

