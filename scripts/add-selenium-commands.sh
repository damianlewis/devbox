#!/usr/bin/env bash

profile_file='/home/vagrant/.profile'

source="\n\n# Run Chrome via Selenium Server
start-chrome() {
    xvfb-run java -Dwebdriver.chrome.driver=/usr/local/bin/chromedriver -jar /usr/local/bin/selenium-server-standalone.jar
}

start-chrome-debug() {
    xvfb-run java -Dwebdriver.chrome.driver=/usr/local/bin/chromedriver -jar /usr/local/bin/selenium-server-standalone.jar -debug
}

# Run Chrome Headless
start-chrome-headless() {
    chromedriver --url-base=/wd/hub
}"

# Append Selenium Server commands to ~/.profile
if ! grep -cqs 'chromedriver' ${profile_file}
then
    printf "$source" >> "$profile_file"
fi

# Re-source user profiles
source ${profile_file}
