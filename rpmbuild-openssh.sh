#!/usr/bin/env bash
set -e 


rhel_version=`rpm -q --queryformat '%{VERSION}' centos-release`
#openssh version
version="8.3p1"
yum install -y pam-devel rpm-build rpmdevtools zlib-devel openssl-devel krb5-devel gcc wget libXt-devel imake gtk2-devel
mkdir -p ~/rpmbuild/SOURCES && cd ~/rpmbuild/SOURCES

wget -c https://mirrors.tuna.tsinghua.edu.cn/OpenBSD/OpenSSH/portable/openssh-${version}.tar.gz
wget -c https://mirrors.tuna.tsinghua.edu.cn/OpenBSD/OpenSSH/portable/openssh-${version}.tar.gz.asc
wget -c https://mirrors.tuna.tsinghua.edu.cn/slackware/slackware64-current/source/xap/x11-ssh-askpass/x11-ssh-askpass-1.2.4.1.tar.gz
# # verify the file

# update the pam sshd from the one included on the system
# the default provided doesn't work properly on CentOS 6.5
tar zxvf openssh-${version}.tar.gz
yes | cp /etc/pam.d/sshd openssh-${version}/contrib/redhat/sshd.pam
mv openssh-${version}.tar.gz{,.orig}
tar zcpf openssh-${version}.tar.gz openssh-${version}
cd
tar zxvf ~/rpmbuild/SOURCES/openssh-${version}.tar.gz openssh-${version}/contrib/redhat/openssh.spec


# edit the specfile
cd openssh-${version}/contrib/redhat/
chown root.root openssh.spec
sed -i -e "s/%define no_gnome_askpass 0/%define no_gnome_askpass 1/g" openssh.spec
sed -i -e "s/%define no_x11_askpass 0/%define no_x11_askpass 1/g" openssh.spec
sed -i -e "s/BuildPreReq/BuildRequires/g" openssh.spec
#if encounter build error with the follow line, comment it.
#sed -i -e "s/PreReq: initscripts >= 5.00/#PreReq: initscripts >= 5.00/g" openssh.spec
#CentOS 7
if [ "${rhel_version}" -eq "7" ]; then
    sed -i -e "s/BuildRequires: openssl-devel < 1.1/#BuildRequires: openssl-devel < 1.1/g" openssh.spec
fi

if [ "${version}" = "8.3p1" ]; then
    sed -i "356a %attr(4711,root,root) %{_libexecdir}/openssh/ssh-sk-helper" openssh.spec
    sed -i "356a %attr(0644,root,root) %{_mandir}/man8/ssh-sk-helper.8.gz" openssh.spec
fi



rpmbuild -ba openssh.spec
cd ~/rpmbuild/RPMS/x86_64/
tar zcvf openssh-${version}-RPMs.el${rhel_version}.tar.gz openssh*
mv openssh-${version}-RPMs.el${rhel_version}.tar.gz ~ && rm -rf ~/rpmbuild ~/openssh-${version}
# openssh-${version}-RPMs.el${rhel_version}.tar.gz ready for use.
