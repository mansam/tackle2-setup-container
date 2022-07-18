# Use Red Hat Universal Base Image 9 - Python 3.9
FROM registry.access.redhat.com/ubi9/python-39:latest

USER root

#COPY collections.yml /tmp/collections.yml
COPY pythonpackages.yml /tmp/pythonpackages.yml


RUN pip3 install -r /tmp/pythonpackages.yml
#RUN ansible-galaxy collection install -r /tmp/collections.yml

RUN adduser deployer --home-dir=/home/deployer  && \
    chmod 770 /home/deployer && \
    chgrp 0 /home/deployer && \
    chmod -R g=u /home/deployer /etc/passwd

COPY deployer.sh /home/deployer/deployer.sh

RUN git clone https://github.com/konveyor/tackle2-hub.git /home/deployer/tackle2-hub

ADD tackle-data /home/deployer/tackle2-hub/hack/tool/tackle-data
COPY tackle-config.yml /home/deployer/tackle2-hub/hack/tool/tackle-config.yml

RUN chmod +x /home/deployer/deployer.sh && \
    chown -R deployer:root /home/deployer

USER deployer
WORKDIR /home/deployer/tackle2-hub/hack/tool

ENTRYPOINT ["/home/deployer/deployer.sh"]

#CMD ["ansible-playbook", "/home/deployer/deployer.yml"]
