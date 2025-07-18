#!/bin/bash -ex

for init_script in /etc/hadoop-init.d/*; do
  "${init_script}"
done

supervisord -c /etc/supervisord.conf
