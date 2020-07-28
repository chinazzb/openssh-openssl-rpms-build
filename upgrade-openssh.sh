#!/usr/bin/env bash
set -e 

version="8.3p1"

# 
yum install createrepo -y
createrepo -po ./ ./RPMS

# add repo file
repo_dir=`pwd`
sudo cat > /etc/yum.repos.d/openssh.repo << EOF
[openssh]
name=openssh-$version
baseurl=file://$repo_dir/
gpgcheck=0
enabled=1
EOF

# install openssl
set +e
rpm -e openssl-libs --nodeps 
rpm -e openssl --nodeps
rpm -e openssl-devel --nodeps
set -e

rpm -ivh ./RPMS/openssl-libs-1.1.1g-19.el7.x86_64.rpm ./RPMS/openssl-devel-1.1.1g-19.el7.x86_64.rpm \
./RPMS/openssl-1.1.1g-19.el7.x86_64.rpm --nodeps

cp ./openssl-libs-1.0.2k/* /usr/lib64/ 
cd /usr/lib64/
ln -sf libcrypto.so.1.0.2k libcrypto.so.10
ln -sf libssl.so.1.0.2k libssl.so.10



 
# install openssh
cd $repo_dir
rpm -U ./RPMS/openssh-$version-1.el7.x86_64.rpm --nodeps --force
rpm -U ./RPMS/openssh-clients-$version-1.el7.x86_64.rpm --nodeps --force
rpm -U ./RPMS/openssh-server-$version-1.el7.x86_64.rpm --nodeps --force

# chmod 600
sudo chmod 600 /etc/ssh/ssh_host_rsa_key
sudo chmod 600 /etc/ssh/ssh_host_ed25519_key
