#!/bin/bash -xe 
# Just a example
# Author: yzhao

setenforce 0
sed -i "s/^SELINUX=.*/SELINUX=disabled/" /etc/selinux/config
systemctl stop firewalld && systemctl disable firewalld

yum install -y virt-manager libvirt qemu-common qemu-kvm qemu-system-x86 libcgroup-tools

systemctl start libvirtd && systemctl enable libvirtd 

[ $# -lt 2 ] && echo 'Usage:auto_create_vm $host_num $host_name' && exit 1
image_path="/var/lib/libvirt/images"
xml_path="/var/libvirt/qemu"
# centos-test.qcow2
# System: Fedora 23 or 25
# username:root
# passwd: redhat
# Date: 2017.01.19
template_image="centos_test.qcow2"

cp 
for i in $(seq $1);do
         filename=${2}-${i}
         cp ./xml/centos_test.xml ${xml_path}/${filename}.xml
         sed -i "s,<name>.*</name>,<name>${filename}</name>,g" ${xml_path}/${filename}.xml
         UUID=`uuidgen`
         sed -i "s,<uuid>.*</uuid>,<uuid>${UUID}</uuid>,g" ${xml_path}/${filename}.xml
         sed -i "s/UUID=.*$/UUID=${UUID}/g" ./ifcfg/ifcfg-eth0
	 sed -i "s/ONBOOT=no/ONBOOT=yes/g"  ./ifcfg/ifcfg-eth0
 #       sed "/HWADDR/c HWADDR=${MAC}" ifcfg-eth0
         cp -rf ./images/${template_image} ${image_path}/${filename}.qcow2
         #sed -i "s,<source file=.*$,<source file='${image_path}/${filename}.qcow2'/>,g" ${filename}.xml
         #MAC="fa:95:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"
         #sed -i "s,<mac address=.*$,<mac address='$MAC'/>,g" ${filename}.xml
         #sed -i "s/HWADDR=.*$/HWADDR=${MAC}/g" ifcfg-eth0
         #sed -i "s/HOSTNAME=.*$/HOSTNAME=${filename}/g" network
         echo $filename > ./hostname/hostname
         virt-copy-in ./ifcfg/ifcfg-eth0 -a ${image_path}/${filename}.qcow2 /etc/sysconfig/network-scripts/
         virt-copy-in ./hostname/hostname -a ${image_path}/${filename}.qcow2 /etc/
         virsh define ${xml_path}/${filename}.xml
         virsh start ${filename}

 done
