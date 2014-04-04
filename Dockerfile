# fuel-cobbler
#
# Version     0.1

FROM centos
MAINTAINER Matthew Mosesohn mmosesohn@mirantis.com

WORKDIR /root

RUN yum install -y yum-utils
RUN yum-config-manager --add-repo=http://srv11-msk.msk.mirantis.net/fwm/4.1/centos/os/x86_64/ --save
RUN yum-config-manager --add-repo=http://10.20.0.2:8080/centos/fuelweb/x86_64/ --save
RUN sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.repos.d/* /etc/yum.conf
RUN rm -f /etc/yum.repos.d/CentOS*
RUN yum --quiet install -y puppet python-pip rubygems-openstack
RUN yum --quiet install -y httpd cobbler dnsmasq
RUN mkdir -p /var/log/nailgun

ADD etc /etc
ADD var /var
RUN cp /etc/puppet/modules/nailgun/examples/cobbler-only.pp /root/init.pp
#Workaround so cobbler can sync
RUN ln -s /proc/mounts /etc/mtab
#Workaround for dnsmasq
RUN echo -e "NETWORKING=yes\nHOSTNAME=$HOSTNAME" > /etc/sysconfig/network
#FIXME workaround for ssh key
RUN mkdir -p /root/.ssh; chmod 700 /root/.ssh; touch /root/.ssh/id_rsa.pub


RUN /etc/init.d/httpd start && puppet apply --trace -d -v /root/init.pp

RUN mkdir -p /usr/local/bin
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 67
EXPOSE 69
EXPOSE 80
EXPOSE 443
CMD /usr/local/bin/start.sh
