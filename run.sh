#!/bin/bash

# Setup a vagrant infra we can use
# ToDo: check we are on centos7
# ToDo: check we are being run as root

yum -y upgrade

cat > /etc/yum.repos.d/vagrant.repo <<- EOM

[sclo7-sclo-vagrant1-sclo-candidate]
name=sclo7-sclo-vagrant1-sclo-candidate
baseurl=http://cbs.centos.org/repos/sclo7-sclo-vagrant1-sclo-candidate/x86_64/os/
gpgcheck=0
enabled=1

[sclo7-rh-ruby22-rh-candidate]
name=sclo7-rh-ruby22-rh-candidate
baseurl=http://cbs.centos.org/repos/sclo7-rh-ruby22-rh-candidate/x86_64/os/
enabled=1
gpgcheck=0

[sclo7-rh-ror41-rh-candidate]
name=sclo7-rh-ror41-rh-candidate
baseurl=http://cbs.centos.org/repos/sclo7-rh-ror41-rh-candidate/x86_64/os/
enabled=1
gpgcheck=0

EOM

# check we have what we think we should have in the repo ( note that this ignores versions of packages ) 
yum --disablerepo=\* --enablerepo=sclo7-sclo-vagrant1-sclo-candidate list available  -d 0  | grep -v 'Available Packages' | cut -f1 -d\  > available_list
diff -uNr expected_packages_list available_list 
if [ $? -ne 0 ]; then 
  echo 'Expected package list did not match the real package list'
  exit 1
fi

yum -y install vagrant1 rsync

if [ $? -eq 0 ]; then
  service libvirtd start
  # we likely dont need to run the rest as root
  git clone https://github.com/CentOS/sig-core-t_functional ~/sync
  cp Vagrantfile ~/sync/
  chmod u+x ./vagrant_test.sh
  scl enable vagrant1 ./vagrant_test.sh
  exit $?
fi
