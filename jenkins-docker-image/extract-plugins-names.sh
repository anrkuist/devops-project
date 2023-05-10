#!/bin/bash
curl https://raw.githubusercontent.com/jenkinsci/jenkins/master/core/src/main/resources/jenkins/install/platform-plugins.json --output platform-plugins.json
cat platform-plugins.json | grep -o 'name.*' | cut -d\  -f2 | sed 's/"//g' | cut -f1 -d"," > plugins_temp.txt
sed 's/$/:latest/' plugins_temp.txt > plugins.txt
rm plugins_temp.txt
rm platform-plugins.json
