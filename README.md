# distr-hw6

# Цели 

Создать свой RPM пакет
Создать свой репозиторий и разместить там ранее собранный RPM



#доставим необходимые пакеты

  
  `yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils`
  

#скачиваем nginx

`wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm`

#При установке такого пакета в домашней директории создается древо каталогов для сборки

 `rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm`

#исходники длā openssl - он потребуетсā при сборке

  ```
  wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz --no-check-certificate
  tar -xvf openssl-1.1.1m.tar.gz
  ```

#Заранее поставим все зависимости чтобý в процессе сборки не бýло ошибок


  `yum-builddep rpmbuild/SPECS/nginx.spec`

#Обратите внимание что путþ до openssl указýваем ДО каталога

  ```
  sed '52s\       --with-cc-opt="%{WITH_CC_OPT}" \' /root/rpmbuild/SPECS/nginx.spec
  sed '52a\       --with-ld-opt="%{WITH_LD_OPT}"' /root/rpmbuild/SPECS/nginx.spec
  ```

#Теперþ можно приступитþ к сборке RPM пакета:

  `rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec`

#Теперþ можно установитþ наш пакет и убедитþсā что nginx работает

  ```
  yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
  systemctl start nginx
  systemctl status nginx
  ```

#Теперь приступим к созданию своего репозитория. Директория для статики у NGINX по
умолчанию /usr/share/nginx/html. Создадим там каталог repo:

  ```
  mkdir /usr/share/nginx/html/repo
  cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
  createrepo /usr/share/nginx/html/repo/
  ```

#Проверяем синтаксис и перезапускаем NGINX

  ```
  nginx -t
  nginx -s reload
  ```

#Проверяем

```
[root@rpm repo]# yum repoinfo otusyum repo-pkgs otus list
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Repo-id      : otus
Repo-name    : otus-linux
Repo-status  : enabled
Repo-revision: 1645464691
Repo-updated : Mon Feb 21 17:31:31 2022
Repo-pkgs    : 1
Repo-size    : 2.1 M
Repo-baseurl : http://localhost/repo/
Repo-expire  : 21 600 second(s) (last: Mon Feb 21 17:48:22 2022)
  Filter     : read-only:present
Repo-filename: /etc/yum.repos.d/otus.repo

```

cat >> /etc/yum.repos.d/otus.repo << EOF

wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

#При добавлении пакетов в репу, выполняем команду

  `createrepo --update /usr/share/nginx/html/repo/`

