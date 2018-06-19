# DevBox

### Introduction
DevBox provides a PHP development environment using Vagrant and VirtualBox. The development VM created is built on Ubuntu with Apache, Nginx, PHP and MySQL. The VM can be configured to use different versions of Ubuntu, PHP and MySQL. It can also be configured to use either Apache or Nginx.


### Configuration
DevBox can be configured using the `config.yaml` configuration file.


#### VM
By default, DevBox will create a private network with an automatically assigned IP address. Use `ifconfig` on the VM to determine the IP address. A static IP address for the VM can be given by adding the `ip` property and assigning an address from the [reserved private address space](https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces). Also the default name for the VM is 'devbox', this can be changed by adding the `name` property. The default hostname for the VM is also 'devbox', this can be changed by adding the `hostname` property.
```yaml
ip: "192.168.22.18"
name: vmname
hostname: vmhostname
```


#### Folders
By default, DevBox will share your project folder `.` with the `/vagrant` folder on the guest machine. To share additional folders with the guest machine `map` the host folder `to` the guest folder in the `folders` array.
```yaml
folders:
    - map: ~/code
      to: /vagrant/code
```

To use NFS for a shared folder, add the `type` property.
```yaml
folders:
    - map: ~/code
      to: /vagrant/code
      type: nfs
```


#### Ubuntu
By default, DevBox uses Ubuntu 16.04. To use a different version, add the `ubuntu` property. Supported versions are `14.04` and `16.04`. 
```yaml
ubuntu: "14.04"
```


#### Webserver
By default, DevBox uses Nginx as the web server. To use a different web server, add the `webserver` property. Supported servers are `nginx` and `apache`. 
```yaml
webserver: apache
```


#### PHP
The VM includes the following PHP modules:
- cli
- curl
- fpm
- mysql
- xdebug

If you require additional PHP modules then they can be added to the `php-modules` array as follows:
```yaml
php-modules:
    - php7.0-gd
    - php7.1-mbstring
    - php7.2-xml
```
**Note**: Modules are installed via Ubuntu's Advanced Packaging Tool (APT)

By default, DevBox uses PHP 7.2. To use a different version for PHP CLI, add the `php-cli` property. Supported versions are `5.6`, `7.0`, `7.1` and `7.2`.
```yaml
php-cli: "5.6"
```
**Note**: PHP version 5.5 is also supported for legacy systems. Use `5` as the `php-cli` property.


#### Website
You can set up multiple sites by mapping a url to a root folder on the VM. Sites are configured in the `sites` array. The url is set via the `url` property and the root folder set via the `root` property.
```yaml
sites:
    - url: site1.test
      root: /path/to/root/folder/on/vm
    - url: site2.test
      root: /path/to/root/folder/on/vm
```

By default, DevBox uses PHP 7.2. To use a different version for a site, add the `php` property. Supported versions are `5.6`, `7.0`, `7.1` and `7.2`.
```yaml
sites:
    - url: site1.test
      root: /path/to/root/folder/on/vm
      php: "7.0"
    - url: site2.test
      root: /path/to/root/folder/on/vm
      php: "7.1"
```
**Note**: PHP version 5.5 is also supported for legacy systems. Add `5` to the `php` sites property.

The url must be added to your machines `hosts` file. Example: 
```
192.168.22.18   site1.test
192.168.22.18   site2.test
```

A self-signed SSL certificate is created for each site, so sites can be accessed via HTTP and HTTPS. 


#### MySQL
By default, DevBox uses MySQL 5.7. To install an alternative version, add the `mysql` property. Supported versions are `5.5`, `5.6` and `5.7`. 
```yaml
mysql: "5.5"
```
**Note**: These alternative versions are only supported with Ubuntu 14.04.

#### Databases
You can create multiple MySQL databases by adding the `name` for the database to the `databases` array.
```yaml
databases:
    - name: dbname1
    - name: dbname2
```

The default user created for a database is `root` with the password `secret`. To change the username and password for a database add the `user` and `password` properties.
```yaml
databases:
    - name: dbname1
      user: user1
      password: secret
    - name: dbname2
      user: tester
      password: secret
```


#### Composer
Composer is included with DevBox. When configuring the VM you can include Composer packages to install globally.
```yaml
composer-packages:
    - laravel/envoy
```


### Post provisioning
Use the `post` file to run any further provisions that you require for your VM.


### Bash aliases
A number of default bash aliases are created for the VM. These can be found in the `aliases` file. Add any further aliases you require to this file before creating the VM.


### Other software included
- Git
- NVM and Node with the following global packages:
    - Bower
    - Grunt
    - Gulp
- Yarn
