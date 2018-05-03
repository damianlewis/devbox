# DevBox

### Introduction
DevBox provides a PHP development environment using Vagrant and VirtualBox. The development VM created is built on Ubuntu with Apache, Nginx, PHP and MySQL. The VM can be configured to use different versions of Ubuntu and PHP. It can also be configured to use either Apache or Nginx.


### Configuration
DevBox can be configured using the `config.yaml` configuration file.


#### VM
The IP address for the VM can be changed by updating the `ip` property. Also the default name for the VM is 'devbox', this can be changed by adding the `name` property. The default hostname for the VM is also 'devbox', this can be changed by adding the `hostname` property.
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
The VM includes the following PHP extensions/modules:
- cli
- curl
- fpm
- mysql
- xdebug

If you require additional PHP extensions/modules then they can be added to the `php-packages` array as follows:
```yaml
php-packages:
    - php7.0-gd
    - php7.1-mbstring
    - php7.2-xml
```
Note: Extensions are installed via Ubuntu's Advanced Packaging Tool (APT)


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

The url must be added to your machines `hosts` file. Example: 
```
192.168.22.18   site1.test
192.168.22.18   site2.test
```

A self-signed SSL certificate is created for each site, so sites can be accessed via HTTP and HTTPS. 

#### Databases
You can create multiple MySQL database by adding the `name` for the database to the `databases` array.
```yaml
databases:
    - name: dbname1
    - name: dbname2
```

The default user created for a database is `damianlewis` with the password `secret`. To change the username and password for a database add the `user` and `password` properties.
```yaml
databases:
    - name: dbname1
      user: user1
      password: secret
    - name: dbname2
      user: tester
      password: secret
```


### Post provisioning
Use the `post` file to run any further provisions that you require for your VM.


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