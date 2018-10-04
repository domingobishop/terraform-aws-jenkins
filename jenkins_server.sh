#!/bin/bash

IP_ADDR=$(getent hosts `hostname` | awk '{print $1}')

sudo yum update -y
sudo yum install -y java-1.8.0-openjdk-devel
sudo yum remove -y java-1.7.0-openjdk

# The Jenkins setup makes use of 'wget', so let's make sure it is installed
sudo yum install -y wget

# Jenkins uses 'ant' so let's make sure it is installed
sudo yum install -y ant

# Let's make sure that 'git' is installed since Jenkins will need this
sudo yum install -y git

# Update the AWS CLI to the latest version
sudo yum update -y aws-cli

# install jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins
sudo service jenkins start
sudo chkconfig jenkins on

# Wait for Jenkins to start for the first time
echo "Waiting 30 seconds for Jenkins to start..."
sleep 30

cd /
sudo mkdir /cli/
cd /cli/
sudo wget -N http://$IP_ADDR:8080/jnlpJars/jenkins-cli.jar

# Hack - edit config.xml, removes security to install plugins (backup file to reinstate later)
cd /var/lib/jenkins/
sudo cp config.xml config-copy.xml
sudo ex +g/useSecurity/d +g/authorizationStrategy/d -scwq /var/lib/jenkins/config.xml
sudo service jenkins restart

# Wait for Jenkins to restart
echo "Waiting 30 seconds for Jenkins to start..."
sleep 30

# install plugins
cd /var/lib/jenkins/plugins/
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin git-client
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin git
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin github-api
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin github-oauth
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin github
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin github-branch-source
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin github-pullrequest
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin codedeploy
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin ec2
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin build-timeout
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin conditional-buildstep
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin msbuild
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin mstest
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin nuget
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin workflow-aggregator
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin pipeline-github-lib
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin subversion
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin tfs
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin timestamper
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin vstestrunner
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080/ install-plugin ws-cleanup

# Be sure to change ownership of all of these downloaded plugins to jenkins:jenkins
sudo chown jenkins:jenkins *.jpi

# Let's restart Jenkins
cd /
sudo java -jar /cli/jenkins-cli.jar -s http://$IP_ADDR:8080 safe-restart

# Update the 'locate' database:
sudo updatedb

# Reinstate config.xml
cd /var/lib/jenkins/
sudo mv config.xml config-old.xml
sudo mv config-copy.xml config.xml
sudo service jenkins restart

rm /tmp/jenkins_server.sh