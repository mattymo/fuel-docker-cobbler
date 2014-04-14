#!/bin/bash
mkdir -p /var/log/cobbler/{anamon,kicklog,syslog,tasks}
#Run puppet to apply custom config
puppet apply -v /etc/puppet/modules/nailgun/examples/cobbler-only.pp
#stop cobbler and dnsmasq
/etc/init.d/dnsmasq stop
/etc/init.d/cobblerd stop

#Set up nailgun DB
/etc/init.d/httpd start
/etc/init.d/xinetd start
dnsmasq -d &
cobblerd -F
