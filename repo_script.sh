#!/bin/bash
#доставим необходимые пакеты
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils
#скачиваем nginx 
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
#При установке такого пакета в домашней директории создается древо каталогов для сборки
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
#исходники длā openssl - он потребуетсā при сборке
wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz --no-check-certificate
tar -xvf openssl-1.1.1m.tar.gz
#Заранее поставим все зависимости чтобý в процессе сборки не бýло ошибок
yum-builddep rpmbuild/SPECS/nginx.spec
sed '52s\	--with-cc-opt="%{WITH_CC_OPT}" \' /root/rpmbuild/SPECS/nginx.spec
sed '52a\	--with-ld-opt="%{WITH_LD_OPT}"' /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx
mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/
/etc/nginx/conf.d/nginx -s reload
cat >> /etc/yum.repos.d/otus.repo << EOF
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo --update /usr/share/nginx/html/repo/