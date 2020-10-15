# -*- coding: utf-8 -*-
#!/usr/bin/python
#python: 2.7.x
#Author: Duan Yu
#mail:chinazzbcn@gmail.com or cn-duanyu@foxmail.com
#Date: 02-01-2019
#version: 0.9
 
 
#SUSE 11 SP3
 
 
import os
 
class system:
    @staticmethod
    def tar():
        #sshTarPath ="/opt/safe/"
        tmpDir = "/tmp/safe/ssh/tar"
        os.system("rm -rf " + tmpDir)
        os.system("mkdir -p " + tmpDir)
        sshTarPath="./openssh-8.4p1.tar"
        if not os.path.exists(sshTarPath):
            print(sshTarPath + " does not exist...................................")
            os._exit(2)
        os.system("tar xvf " + sshTarPath + " -C " + tmpDir)
        os.system("for i in /tmp/safe/ssh/tar/openssh-8.4p1/*.tar.gz; do tar zxvf  $i -C /tmp/safe/ssh/ ;done")
 
    @staticmethod
    def config():
        #zlib
        os.system("clear")
        checkZlib =os.system("cd /tmp/safe/ssh/zlib* && ./configure --shared && make && make install")
        if 0 != checkZlib:
            print("config zlib fault")
            os._exit(3)
 
 
        #openssl
        os.system("clear")
        checkOpenssl = os.system("cd /tmp/safe/ssh/openssl* && ./config shared && make && make install")
        if 0 != checkOpenssl:
            print("config openssl fault")
            os._exit(4)
 
        #backup openssl
        os.system("clear")
        os.system("mv /usr/bin/openssl /usr/bin/openssl.bak")
        os.system("ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl")
        os.system("echo /usr/local/ssl/lib >> /etc/ld.so.conf")
        os.system("ldconfig")
 
 
        #openssh
        os.system("clear")
        os.system("rpm -e openssh --nodeps && mv /etc/ssh /etc/sshbak")
        #hide version
        tools.replace("/tmp/safe/ssh/openssh-8.4p1/version.h","OpenSSH_8.4","OpenSSH")
        #make
        checkOpenssh = os.system("cd /tmp/safe/ssh/openssh*/ && ./configure --prefix=/usr/ --sysconfdir=/etc/ssh "
                  "--with-zlib --with-ssl-dir=/usr/local/ssl --with-md5-passwords mandir=/usr/share/man "
                  "&& make && make install")
        if 0 != checkOpenssh:
            print("config openssh fault")
            os._exit(5)
 
        os.system("service sshd stop && mv /etc/init.d/sshd /etc/init.d/sshd.bak")
        os.system("cp -p /tmp/safe/ssh/openssh*/contrib/suse/rc.sshd /etc/init.d/sshd")
        os.system("chmod +x /etc/init.d/sshd && chkconfig --add sshd")
        os.system("cp -f -r /usr/sbin/sshd /usr/sbin/sshd.bak")
        os.system("cp -f -r /tmp/safe/ssh/openssh-*/sshd_config /etc/ssh/sshd_config ")
        os.system("cp -f -r /tmp/safe/ssh/openssh-*/sshd /usr/sbin/sshd")
        os.system("cp -f -r /tmp/safe/ssh/openssh-*/ssh /usr/sbin/ssh")
 
        #root login
        tools.replace("/etc/ssh/sshd_config","#PermitRootLogin prohibit-password","PermitRootLogin yes")
        os.system("service sshd start")
 
 
class tools:
    @staticmethod
    def replace(file_path, old_str, new_str):
        try:
            f = open(file_path,'r+')
            all_lines = f.readlines()
            f.seek(0)
            f.truncate()
            for line in all_lines:
                line = line.replace(old_str, new_str)
                f.write(line)
            f.close()
        except Exception,e:
            print e
 
def install_ssh():
    system.tar()
    system.config()
 
if __name__ == '__main__':
    install_ssh()