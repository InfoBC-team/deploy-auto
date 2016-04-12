#!/bin/sh
echo "starting deploy to voyhoyrocks from "$1"......"

cd /home/voyhoy/voyhoy-core
git checkout master
git pull origin master
date=`date`
echo "| "$date" ###################### voyhoy-core is ready ######################"

cd /home/voyhoy/lab-grails-app
git fetch
git checkout $1
git pull origin $1

date=`date`
echo "| "$date" - ###################### lab-grails-app is ready ######################"

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$version" | tr -d '[[:space:]]')
./grailsw clean
./grailsw -Dgrails.env=test war target/voyhoy-$1-$version.war
date=`date`
echo "| "$date" - ###################### ("$1") War compiled successfully ######################"

date=`date`
aws s3 cp target/voyhoy-$1-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/voyhoy-$1-$version.war
echo "| "$date" - ###################### ("$1") War uploaded successfully on elasticbeanstalk ######################"

date=`date`
aws elasticbeanstalk create-application-version --region sa-east-1 --application-name "My First Elastic Beanstalk Application" --version-label voyhoy-$1-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=voyhoy-$1-$version.war
echo "| "$date" - ###################### ("$1") Application-version created successfully on elasticbeanstal ######################"
