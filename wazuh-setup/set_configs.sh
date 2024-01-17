#!/bin/bash

# create backups
mv /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.back &&
mv /var/ossec/etc/shared/default/agent.conf /var/ossec/etc/shared/default/agent.conf.back &&

# add new configs to their paths
cp ossec.conf /var/ossec/etc/ossec.conf &&
cp agent.conf /var/ossec/etc/shared/default/agent.conf &&

systemctl restart wazuh-manager

echo "done"
