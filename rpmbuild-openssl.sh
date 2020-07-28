#!/usr/bin/env bash
set -e 

home_dir=`pwd`
rhel_version=`rpm -q --queryformat '%{VERSION}' centos-release`
version=1.1.1g

# download
yum install git wget rpm-build krb5-devel lksctp-tools-devel perl-Test-Harness perl-Module-Load-Conditional perl-Test-Simple -y
mkdir -p ~/rpmbuild/SOURCES && cd ~/rpmbuild/SOURCES
git clone https://src.fedoraproject.org/rpms/openssl.git
mv openssl/* ./
wget -c https://www.openssl.org/source/openssl-$version.tar.gz --no-check-certificate

# rpmbuild
/usr/bin/cp -f  $home_dir/specs/openssl.spec ~/rpmbuild/SOURCES/
rpmbuild -ba openssl.spec

# centos rpm tar
rpms_dir=~/rpmbuild/RPMS/x86_64

cd $rpms_dir
tar cvf openssl-$version.tar openssl-$version*.rpm openssl-libs*.rpm openssl-devel*.rpm

cd /root/rpmbuild/RPMS/x86_64/
tar zcvf openssl-${version}-RPMS.el${rhel_version}.tar.gz openssl*
mv openssl-${version}-RPMS.el${rhel_version}.tar.gz ~ && rm -rf ~/rpmbuild



