#!/bin/bash
mkdir -p /opt/contrail/contrail_install_repo;
scp contrail-networking-dependents_4.0.0.0-20.tgz contrail-networking-thirdparty_4.0.0.0-20.tgz contrail-vrouter-packages_4.0.0.0-20.tgz root@10.87.29.94:/opt/contrail/contrail_install_repo/.;
cd /opt/contrail/contrail_install_repo && tar -xvzf contrail-networking-dependents_4.0.0.0-20.tgz;
cd /opt/contrail/contrail_install_repo && tar -xvzf contrail-vrouter-packages_4.0.0.0-20.tgz;
cd /opt/contrail/contrail_install_repo && tar -xvzf contrail-networking-thirdparty_4.0.0.0-20.tgz;
#cd /opt/contrail/contrail_install_repo && mkdir Packages;
#cd /opt/contrail/contrail_install_repo && cp * Packages/.;
apt-get update -y;

cd /etc/apt/
# create repo with only local packages
datetime_string=`date +%Y_%m_%d__%H_%M_%S`
cp sources.list sources.list.$datetime_string
echo "deb file:/opt/contrail/contrail_install_repo ./" > local_repo

#modify /etc/apt/soruces.list/ to add local repo on the top
grep "^deb file:/opt/contrail/contrail_install_repo ./" sources.list

if [ $? != 0 ]; then  
     cat local_repo sources.list > new_sources.list
     mv new_sources.list sources.list
fi

# Allow unauthenticated pacakges to get installed.
# Do not over-write apt.conf. Instead just append what is necessary
# retaining other useful configurations such as http::proxy info.
apt_auth="APT::Get::AllowUnauthenticated \"true\";"
grep --quiet "^$apt_auth" apt.conf
if [ "$?" != "0" ]; then
    echo "$apt_auth" >> apt.conf
fi

#scan pkgs in local repo and create Packages.gz
apt-get install dpkg-dev
cd /opt/contrail/contrail_install_repo
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
apt-get update -y

apt-get install contrail-vrouter-dkms -y
apt-get install contrail-vrouter-agent -y
apt-get install contrail-utils -y
apt-get install contrail-vrouter-common -y
apt-get install contrail-vrouter-init -y
apt-get install contrail-nodemgr -y
