#!/bin/bash

<<comment
This is a multi-line comment
comment

#This is a single line comment

environment="Dev"

echo "This is a $environment environment machine, system uptime is: "
echo $(uptime)

echo "Enter the purpose for logging in:" 
read purpose
echo "Purpose has been noted! Have a nice day"
echo "$(date) - $(whoami) logged in for: $purpose purposes">> login-logs.txt

