#!/bin/bash

#installations and script must and should be run through root user
# need to run sudo su --> to switch root user

#Copying to the S3 bucket will require AWS Command Line Interface (CLI), we need to install awscli before run or test the script
#Install awscli
apt-get update -y
apt install awscli

#S3 bucket name as varible
s3_bucket="upgrad-venkatarao"

#my name
myname="venkatarao"



#Update all the ubuntu repositories
apt-get update -y

# Check if apache2 is installed or not
apache=$(dpkg --get-selections apache2)
if [[ $apache == *"apache2"* ]]; then
   echo "apache2 is already installed."
else
	echo "apache2 is not installed."
	apt install apache2 -y
fi


# apache2 Service is running or not
servicestart=$(systemctl status apache2)

if [[ $servicestart == *"active (running)"* ]]; then
        echo "Apache Service is running."
else
        echo "Apache Service is not running."
        systemctl start apache2
fi

# Check apache2 Service is enabled or disabled
apache2enabled=$(systemctl is-enabled apache2)
if [[ $apache2enabled == "enabled" ]]; then
	echo "Apache service is enabled."
else
	echo "Apache service is disabled."
	systemctl enable apache2
fi

# Creating timestamp with format
timestamp=$(date '+%d%m%Y-%H%M%S')
# Create tar archive for apache2 access and error logs and stored into /tmp
tar -c -C /var/log/apache2 ./*.log -f /tmp/${myname}-httpd-logs-${timestamp}.tar


# copy logs to s3 bucket
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar