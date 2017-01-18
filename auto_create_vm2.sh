#!/bin/bash
# just a example 
[ $# -lt 2 ] && echo 'Usage:auto_create_vm $host_num $host_name' && exit 1
image_path="/home/vm1"
#centos-lxc.qcow2 RHEL7.3
#username:root
#passwd: redhat
template_image="centos-lxc.qcow2"
for i in $(seq $1);do
         filename=${2}-${i}
         cp centos-lxc.xml ${filename}.xml
         sed -i "s,<name>.*</name>,<name>${filename}</name>,g" ${filename}.xml
         UUID=`uuidgen`
         sed -i "s,<uuid>.*</uuid>,<uuid>${UUID}</uuid>,g" ${filename}.xml
         sed -i "s/UUID=.*$/UUID=${UUID}/g" ifcfg-eth0
 #       sed "/HWADDR/c HWADDR=${MAC}" ifcfg-eth0
         cp -rf ${image_path}/${template_image} ${image_path}/${filename}.qcow2
         sed -i "s,<source file=.*$,<source file='${image_path}/${filename}.qcow2'/>,g" ${filename}.xml
         MAC="fa:95:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"
         sed -i "s,<mac address=.*$,<mac address='$MAC'/>,g" ${filename}.xml
         sed -i "s/HWADDR=.*$/HWADDR=${MAC}/g" ifcfg-eth0
 #       sed -i "s/HOSTNAME=.*$/HOSTNAME=${filename}/g" network
         echo $filename > hostname
         virt-copy-in ifcfg-eth0 -a ${image_path}/${filename}.qcow2 /etc/sysconfig/network-scripts/
         virt-copy-in hostname -a ${image_path}/${filename}.qcow2 /etc/
         virsh define ${filename}.xml
         virsh start ${filename}
 done 
