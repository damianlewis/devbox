#!/usr/bin/env bash

[[ -n "$1" ]] && chromedriver_ver=$1 || chromedriver_ver=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`
is_updated=0

# Install Google Chrome.
if [[ -f "/usr/bin/google-chrome-stable" ]]
then
    echo 'Google Chrome already installed'
else
    curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add > /dev/null 2>&1
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
    apt-get update > /dev/null 2>&1
    is_updated=1
    apt-get -y install google-chrome-stable > /dev/null 2>&1
fi

# Install ChromeDriver.
if [[ -f "/usr/local/bin/chromedriver" ]]
then
    echo 'ChromeDriver already installed'
else
    if [[ ${is_updated} == 0 ]]
    then
        apt-get update > /dev/null 2>&1
        is_updated=1
    fi
    apt-get -y install unzip > /dev/null 2>&1
    wget -N http://chromedriver.storage.googleapis.com/${chromedriver_ver}/chromedriver_linux64.zip -P ~/ > /dev/null 2>&1
    unzip ~/chromedriver_linux64.zip -d ~/ > /dev/null 2>&1
    rm ~/chromedriver_linux64.zip
    mv -f ~/chromedriver /usr/local/bin/chromedriver
fi

# Install Xvfb.
if [[ -f "/usr/bin/Xvfb" ]]
then
    echo "Xvfb already installed"
else
    if [[ ${is_updated} == 0 ]]
    then
        apt-get update > /dev/null 2>&1
    fi
    apt-get -y install xvfb > /dev/null 2>&1
fi