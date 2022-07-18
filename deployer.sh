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
echo "Tackle 2 URL: ${TACKLE2_URL}"
echo "  User:       ${TACKLE2_USER}"
echo "  Password:   ${TACKLE2_PASSWORD}"

cd $HOME/tackle2-hub/hack/tool
sed -i "s/REPLACE_URL/${TACKLE2_URL}/g" tackle-config.yml

if [ -n "$TACKLE2_USER" ];
then
  sed -i "s/REPLACE_USER/${TACKLE2_USER}/g" tackle-config.yml
fi

if [ -n "$TACKLE2_PASSWORD" ];
then
  sed -i "s/REPLACE_PASSWORD/${TACKLE2_PASSWORD}/g" tackle-config.yml
fi

# Clean all Tackle data
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
./tackle clean-all

# Import provided data
./tackle import

