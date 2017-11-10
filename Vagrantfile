# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

settings = YAML::load(File.read("devbox.yaml"))
post_script = "post.sh"
aliases = "aliases"
script_dir = File.expand_path("scripts", File.dirname(__FILE__))

supported_webservers = ["apache", "nginx"]
supported_mysql = ["5.5", "5.6", "5.7"]

default_mysql = "5.7"

webserver = settings["webserver"] ||= "nginx"
mysql_ver = settings["mysql-ver"] ||= default_mysql

unless supported_webservers.include?(webserver)
    abort("Web server #{webserver} not recognised. Only #{supported_webservers} are supported.")
end

unless supported_mysql.include?(mysql_ver)
    abort("MySQL version #{mysql_ver} not supported. Only versions #{supported_mysql} are currently supported.")
end

# Synced folder
folder = {
    "map" => ".",
    "to" => "/vagrant"
}

# Default ports for forwarding
default_ports = {
    80 => 8000,
    443 => 44300,
    3306 => 33060
}

Vagrant.configure("2") do |config|
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

    # Prevent TTY errors (https://coderwall.com/p/qtbi5a/prevent-stdin-is-not-a-tty-error-in-vagrant)
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Enable SSH agent forwarding
    config.ssh.forward_agent = true

    # Configure the vagrant box
    config.vm.define settings["name"] ||= "devbox"
    config.vm.box = "damianlewis/devbox"
    config.vm.box_version = ">= 1.0.0, < 2.0.0"
    config.vm.network "private_network", ip: settings["ip"] ||= "192.168.10.10"
    config.vm.hostname = settings["hostname"] ||= "devbox"

    # Configure VirtualBox settings
    config.vm.provider "virtualbox" do |vb|
        vb.name = settings["name"] ||= "devbox"
        vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
        vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", settings["natdnshostresolver"] ||= "off"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", settings["natdnsproxy"] ||= "off"]
        if settings.has_key?("gui") && settings["gui"] == true
            vb.gui = true
        end
    end

    # Configure default ports
    default_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    # Configure shared folder
    if settings.has_key?("nfs") && settings["nfs"] == true
        config.vm.synced_folder folder["map"], folder["to"], type: "nfs", mount_options: ['actimeo=1', 'nolock']
    else
        config.vm.synced_folder folder["map"], folder["to"]
    end

    # Install additional PHP extensions/modules
    if settings.has_key?("extensions") && settings["extensions"].kind_of?(Array)
        extensions = settings["extensions"]
        config.vm.provision "shell" do |s|
            s.name = "Installing additional PHP extensions"
            s.path = script_dir + "/install-extensions.sh"
            s.args = extensions
        end
    end

    # Install Xdebug
    if settings.has_key?("xdebug") && settings["xdebug"] == true
        config.vm.provision "shell" do |s|
            s.name = "Installing Xdebug"
            s.path = script_dir + "/install-xdebug.sh"
        end
    end

    # Install Laravel Envoy
    if settings.has_key?("envoy") && settings["envoy"] == true
        config.vm.provision "shell" do |s|
            s.name = "Installing Laravel Envoy"
            s.path = script_dir + "/install-envoy.sh"
            s.privileged = false
        end
    end

    # Switch MySQL version
    if mysql_ver != default_mysql
        config.vm.provision "shell" do |s|
            s.name = "Switching MySQL to version #{mysql_ver}"
            s.path = script_dir + "/switch-mysql.sh"
            s.args = [mysql_ver]
        end
    end

    # Create site
    if settings.has_key?("site")
        config.vm.provision "shell" do |s|
            s.name = "Creating Site: " + settings["site"]
            s.path = script_dir + "/serve-#{webserver}.sh"
            s.args = [settings["site"], settings["root"] ||= folder["to"]]
        end
    end

    # Create all the configured databases
    if settings.has_key?("databases") && settings["databases"].kind_of?(Array)
        settings["databases"].each do |db|
            config.vm.provision "shell" do |s|
                s.name = "Creating MySQL Database: " + db
                s.path = script_dir + "/create-mysql.sh"
                s.args = [db, "devbox", "secret"]
            end
        end
    end

    # Run post provisioning script
    if File.exists? post_script
        config.vm.provision "shell", path: post_script
    end
end