#!/usr/bin/env bash

java_ver=$1
selenium_ver=$2
selenium_sub_dir=$(echo "$selenium_ver" | cut -d"." -f-2)

# Install Java JRE
if [[ -f "/usr/bin/java" ]]
then
    echo 'Java already installed'
else
    apt-get update > /dev/null 2>&1
    apt-get -y install openjdk-${java_ver}-jre-headless > /dev/null 2>&1
fi

# Install Selenium Server Standalone
if [[ -f "/usr/local/bin/selenium-server-standalone.jar" ]]
then
    echo 'Selenium Server Standalone already installed'
else
    wget -N http://selenium-release.storage.googleapis.com/${selenium_sub_dir}/selenium-server-standalone-${selenium_ver}.jar -P ~/ > /dev/null 2>&1
    mv -f ~/selenium-server-standalone-${selenium_ver}.jar /usr/local/bin/selenium-server-standalone.jar
fi