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
echo "Tackle2 User:     ${TACKLE2_USER}"
echo "Tackle2 Password: ${TACKLE2_PASSWORD}"

export TACKLE_NOAUTH="--no-auth"

cd $HOME/tackle2-hub/hack/tool

if [ -n "$TACKLE2_USER" ];
then
  sed -i "s/REPLACE_USER/${TACKLE2_USER}/g" ./tackle-config.yml
  TACKLE_NOAUTH=""
fi

if [ -n "$TACKLE2_PASSWORD" ];
then
  sed -i "s/REPLACE_PASSWORD/${TACKLE2_PASSWORD}/g" ./tackle-config.yml
fi

# Wait until the Tackle UI service is available
export CURL_RC=7
while [ "$CURL_RC" != "0" ]
do
  sleep 5
  CURL_RC=$(curl -sI http://tackle-ui:8080 -o /dev/null)
done

# Clean all Tackle data
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
./tackle ${TACKLE_NOAUTH} clean-all

# Import provided data
./tackle ${TACKLE_NOAUTH} import

