# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

settings = YAML::load(File.read("config.yaml"))
post_script = "post"
aliases = "aliases"
script_dir = File.expand_path("scripts", File.dirname(__FILE__))

supported_php = ["5", "5.6", "7.0", "7.1", "7.2"]
supported_ubuntu = ["14.04", "16.04"]
supported_webservers = ["apache", "nginx"]
supported_mysql = ["5.5", "5.6", "5.7"]

default_chromedriver = "latest"
default_php = "7.2"
default_selenium = "3.9.1"
default_ubuntu = "16.04"
default_webserver = "nginx"

if settings.has_key?("ubuntu")
    unless supported_ubuntu.include?(settings["ubuntu"])
        abort("Web server #{settings["webserver"]} not recognised. Only #{supported_webservers} are currenly supported with DevBox.")
    end
end

if settings.has_key?("webserver")
    unless supported_webservers.include?(settings["webserver"])
        abort("Web server #{settings["webserver"]} not recognised. Only #{supported_webservers} are currenly supported with DevBox.")
    end

    webserver = settings["webserver"]
else
    webserver = default_webserver
end

hostname = settings["hostname"] ||= "devbox"
name = settings["name"] ||= "devbox"

# Default ports for forwarding
default_ports = {
    80 => 8000,
    3306 => 33060
}

Vagrant.configure("2") do |config|
    # Set the VM provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = settings["provider"] ||= "virtualbox"

    # Create bash aliases
    if File.exists? aliases
        config.vm.provision "file", source: aliases, destination: "~/.bash_aliases"
    end

    # Check the guest additions when booting this machine
    if Vagrant.has_plugin?("vagrant-vbguest")
        unless settings.has_key?("vbguest") && settings["vbguest"] == true
            config.vbguest.auto_update = false
        end
    end

    # Enable SSH agent forwarding
    config.ssh.forward_agent = true

    # Configure the vagrant box
    config.vm.define name
    config.vm.hostname = hostname
    config.vm.box = settings["box"] ||= "damianlewis/ubuntu-#{settings["ubuntu"] ||= default_ubuntu}-#{webserver == "apache" ? "lamp" : "lemp"}"
    config.vm.box_version = settings["version"] ||= ">= 1.0"

    # Configure default ports
    default_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    # Configure additional ports to forward
    if settings.has_key?("ports")
        settings["ports"].each do |port|
            config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], auto_correct: true
        end
    end

    # Configure networks
    if settings.has_key?("networks")
        settings["networks"].each do |network|
            if network.has_key?("type")
                if network["type"] == "private"
                    if network.has_key?("ip")
                        config.vm.network "private_network", ip: network["ip"]
                    else
                        config.vm.network "private_network", type: "dhcp"
                    end
                end

                if network["type"] == "bridged"
                    if network.has_key?("ip")
                        config.vm.network "public_network", ip: network["ip"], bridge: network["bridge"] ||= nil
                    else
                        config.vm.network "public_network", bridge: network["bridge"] ||= nil
                    end
                end
            end
        end
    else
        config.vm.network "private_network", type: "dhcp"
    end

    # Configure VirtualBox settings
    config.vm.provider "virtualbox" do |vb|
        vb.name = name
        vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
        vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", settings["natdnshostresolver"] ||= "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", settings["natdnsproxy"] ||= "on"]
        vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
        if settings.has_key?("gui") && settings["gui"] == true
            vb.gui = true
        end
    end

    # Configure shared folders
    if settings.has_key?("folders")
        settings["folders"].each do |folder|
            if folder["type"] == "nfs"
                config.vm.synced_folder folder["map"], folder["to"], type: "nfs", mount_options: ['actimeo=1', 'nolock']
            else
                config.vm.synced_folder folder["map"], folder["to"]
            end
        end
    else
        config.vm.synced_folder ".", "/vagrant"
    end

    # Install additional Ubuntu packages
    if settings.has_key?("apt-packages")
        settings["apt-packages"].each do |package|
            config.vm.provision "shell" do |s|
                s.name = "Installing APT package [#{package}]"
                s.path = "#{script_dir}/install-apt-package"
                s.args = package
            end
        end

        config.vm.provision "shell" do |s|
            s.name = "Restarting PHP-FPM"
            s.path = "#{script_dir}/restart-php"
            s.args = supported_php
        end
    end

    # Install global Composer packages
    if settings.has_key?("composer-packages")
        settings["composer-packages"].each do |package|
            config.vm.provision "shell" do |s|
                s.name = "Installing Composer package [#{package}]"
                s.path = "#{script_dir}/install-composer-package"
                s.args = package
                s.privileged = false
            end
        end
    end

    # Install components for browser testing
    if settings.has_key?("browser-testing") && settings["browser-testing"] == true
        config.vm.provision "shell" do |s|
            s.name = "Installing Java JRE"
            s.path = "#{script_dir}/install-java"
            s.args = settings["java"] ||= nil
        end

        config.vm.provision "shell" do |s|
            s.name = "Installing Selenium Server"
            s.path = "#{script_dir}/install-selenium"
            s.args = settings["selenium"] ||= nil
        end

        config.vm.provision "shell" do |s|
            s.name = "Installing Google Chrome"
            s.path = "#{script_dir}/install-google-chrome"
        end

        config.vm.provision "shell" do |s|
            s.name = "Installing ChromeDriver"
            s.path = "#{script_dir}/install-chromedriver"
            s.args = settings["chromedriver"] ||= nil
        end

        config.vm.provision "shell" do |s|
            s.name = "Installing Xvfb"
            s.path = "#{script_dir}/install-xvfb"
        end

        config.vm.provision "shell" do |s|
            s.name = "Adding Selenium Server bash commands"
            s.path = "#{script_dir}/add-selenium-commands"
        end
    end

    # Fix for issue with Nginx 1.13.12 not starting on damianlewis/ubuntu-16.04-lemp box
    if config.vm.box == "damianlewis/ubuntu-16.04-lemp"
        config.vm.provision "shell", run: "always" do |s|
            s.name = "Starting Nginx"
            s.inline = "service nginx restart > /dev/null 2>&1"
        end
    end

    # Create all the configured sites
    if settings.has_key?("sites")
        settings["sites"].each do |site|
            config.vm.provision "shell" do |s|
                s.name = "Creating SSL certificate for [#{site["url"]}]"
                s.path = "#{script_dir}/create-ssl-certificate"
                s.args = [site["url"]]
            end

            if site.has_key?("php")
                unless supported_php.include?(site["php"])
                    abort("PHP version #{site["php"]} not recognised. Only versions #{supported_php} are currenly supported with DevBox.")
                end
            end

            config.vm.provision "shell" do |s|
                s.name = "Creating site [#{site["url"]}] with PHP #{site["php"] ||= default_php}"
                s.path = "#{script_dir}/serve-#{webserver}"
                s.args = [site["url"], site["root"], site["php"] ||= default_php]
            end
        end

        config.vm.provision "shell" do |s|
            s.name = "Restarting #{webserver.capitalize}"
            s.inline = "service $1 restart > /dev/null 2>&1"
            s.args = [webserver == "apache" ? "apache2" : "nginx"]
        end
    end

    # Install alternatative version of MySQL
    if settings.has_key?("mysql")
        unless supported_mysql.include?(settings["mysql"])
            abort("MySQL version #{settings["mysql"]} not recognised. Only versions #{supported_mysql} are currenly supported with DevBox.")
        end

        config.vm.provision "shell" do |s|
            s.name = "Installing MySQL #{settings["mysql"]}"
            s.path = "#{script_dir}/install-mysql"
            s.args = settings["mysql"]
        end
    end

    # Create all the configured MySQL databases
    if settings.has_key?("databases")
        settings["databases"].each do |db|
            config.vm.provision "shell" do |s|
                s.name = "Creating MySQL database [#{db["name"]}]"
                s.path = "#{script_dir}/create-mysql"
                s.args = [db["name"], db["user"] ||= "damianlewis", db["password"] ||= "secret"]
            end
        end

        config.vm.provision "shell" do |s|
            s.name = "Restarting MySQL"
            s.inline = "service mysql restart > /dev/null 2>&1"
        end
    end

    # Set alternative PHP version for CLI
    if settings.has_key?("php-cli")
        unless supported_php.include?(settings["php-cli"])
            abort("PHP version #{settings["php-cli"]} not recognised. Only versions #{supported_php} are currenly supported with DevBox.")
        end

        config.vm.provision "shell" do |s|
            s.name = "Setting alternative PHP CLI to PHP #{settings["php-cli"]}"
            s.path = "#{script_dir}/set-php-cli"
            s.args = settings["php-cli"]
        end
    end

    # Run post provisioning script
    if File.exists? post_script
        config.vm.provision "shell", path: post_script
    end
end