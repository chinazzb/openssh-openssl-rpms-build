# Precautions
<font color=red>Based on openssl-1.1.1g, the system default openssl-1.0.2k openssl-devel-1.0.2k openssl-libs-1.0.2k will be delete</font>

openssh disables remote root login by default

enable modify the configuration item PermitRootLogin yes 

#PermitRootLogin yes

PermitRootLogin yes

# Introduction
## openssh:

reference https://github.com/Junyangz/upgrade-openssh-centos/blob/master/README.md
openssh-8.2p1 rpm spec file has bug , Two files are missing. man8/ssh-sk-helper.8.gz and openssh/ssh-sk-helper

So script add: 
```shell
if [ "${version}" = "8.2p1" ]; then
    sed -i "356a %attr(4711,root,root) %{_libexecdir}/openssh/ssh-sk-helper" openssh.spec
    sed -i "356a %attr(0644,root,root) %{_mandir}/man8/ssh-sk-helper.8.gz" openssh.spec
fi
```
## openssl:
reference to centos official spec and https://src.fedoraproject.org/rpms/openssl/blob/master/f/openssl.spec
### get centos official
wget -c http://vault.centos.org/7.7.1908/os/Source/SPackages/openssl-1.0.2k-19.el7.src.rpm

rpm2cpio openssl-1.0.2k-19.el7.src.rpm | cpio -civ '*.spec'

# Instructions
upgrade:

* bash ./upgrade-openssh.sh 

rpmbuild:

* bash ./rpmbuild-openssh.sh
* bash ./rpmbuild-openssl.sh


# changlog
2020-10-16:
    Upgrade openssh-8.3p1 to openssh-8.4p1
    Tried to hide the version number, but failed

2020-07-28:
    Upgrade openssh-8.2p1 to openssh-8.3p1
    Hide server version numbern


2020-05-15:
   Compile based on openssl-devel-1.1.1g


