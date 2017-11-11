# DevBox

### Introduction
DevBox provides a PHP development environment using Vagrant and VirtualBox. The development VM created is built on Ubuntu with Apache, Nginx, PHP and MySQL. The VM can be configured to use different versions of Ubuntu, PHP and MySQL. It can also be configured to use either Apache or Nginx.


### Configuration
The VM can be configured using the `devbox.yaml` configuration file.


#### VM
The IP address for the VM can be changed by updating the `ip` property. Also the default name for the VM is 'devbox', this can be changed by adding the `name` property. The default hostname for the VM is also 'devbox', this can be changed by adding the `hostname` property.
```
ip: "192.168.22.18"
name: vmname
hostname: vmhostname
```
To use NFS for your synced folder, add the `nfs` property.
```
nfs: true
```


#### Ubuntu
By default the VM uses Ubuntu 16.04. To use a different version, add/update the `ubuntu-ver` property. Supported versions are `14.04` and `16.04`. 
```
ubuntu-ver: "14.04"
```


#### Webserver
By default the VM uses Nginx as the webserver. To use a different webserver, add/update the `webserver` property. The webservers supported are `nginx` and `apache`. 
```
webserver: apache
```


#### PHP
By default the VM uses PHP 7.1. To use a different version, add/update the `php-ver` property. Supported versions are `5.6`, `7.0` and `7.1`.
```
php-ver: "7.0"
```
Note: PHP version 5.5 is also supported but this version is now EOL.

The VM includes the following PHP extensions/modules:
- cli
- curl
- fpm
- mysql

If you require additional PHP extensions/modules then they can be added to the `extenstion` property as follows:
```
extensions:
    - php5-gd
    - php5-json
    - php5-mcrypt
```
Note: Extensions are installed via Ubuntu's Advanced Packaging Tool (APT)


#### MySQL
By default the VM uses MySQL 5.7. To use a different version, add/update the `mysql-ver` property. Supported versions are `5.5`, `5.6` and `5.7`.
```
mysql-ver: "5.6"
```


#### Website
You can set up a site by mapping a domain name to a root folder on the VM. The domain name is set via the `site` property and the root folder set via the `root` property. By default the root folder will be set to `/vagrant`.
```
site: site.dev
root: /path/to/root/folder/on/vm
```
The domain name must be added to your machines `hosts` file. Example: 
```
192.168.22.18   mysite.dev
```


#### Databases
You can create a MySQL database by adding the name for the database to the `databases` property.
```
databases:
    - dbname
```
Multiple databases can be created as follows:
```
databases:
    - dbname
    - dbname
    - dbname
```
The default user created for the databases is `devbox` with the password `secret`.


#### Xdebug
To install Xdebug add the following `xdebug` property:
```
xdebug: true
```


#### Laravel Envoy
To install Laravel Envoy add the following `envoy` property:
```
envoy: true
```


### Post provisioning
Use the `post.sh` file to run any further provisions that you require for your VM.


### Bash aliases
A number of default bash aliases are created for the VM. These can be found in the `aliases` file. Add any further aliases you require to this file before creating the VM.


### Other software included
- Git
- Composer
- NVM and Node with the following global packages:
    - Bower
    - Grunt
    - Gulp
- Yarn