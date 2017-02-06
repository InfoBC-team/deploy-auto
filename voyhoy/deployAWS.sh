#!/bin/sh
echo "starting......"
./grailsw --version

cd /home/voyhoy/voyhoy-core
git fetch
git checkout $1
git pull origin $1

date=`date`
echo "| "$date" ###################### voyhoy-core ("$1") is ready ######################"

cd /home/voyhoy/lab-grails-app
git fetch
git checkout $1
git pull origin $1

date=`date`
echo "| "$date" - ###################### lab-grails-app ("$1") is ready ######################"

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$version" | tr -d '[[:space:]]')

if [ "$1" = "legacy" ] && [ ! -f "target/legacy.voyhoy.com-$version.war" ]; then
	./grailsw clean
	./grailsw war target/legacy.voyhoy.com-$version.war
	date=`date`
	echo "| "$date" - ###################### (legacy) War compiled successfully ######################"

	date=`date`
	aws s3 cp target/legacy.voyhoy.com-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/legacy.voyhoy.com-$version.war
	echo "| "$date" - ###################### (legacy) War uploaded successfully on elasticbeanstalk ######################"

	date=`date`
	aws elasticbeanstalk create-application-version --region sa-east-1 --application-name "My First Elastic Beanstalk Application" --version-label legacy.voyhoy.com-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=legacy.voyhoy.com-$version.war
	echo "| "$date" - ###################### (legacy) Application-version created successfully on elasticbeanstal ######################"
fi

if [ "$1" = "master" ] && [ ! -f "target/voyhoy.com-$version.war" ]; then
	./grailsw clean
	./grailsw war target/voyhoy.com-$version.war
	date=`date`
	echo "| "$date" - ###################### (production-new) War compiled successfully ######################"

	date=`date`
	aws s3 cp target/voyhoy.com-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/voyhoy.com-$version.war
	echo "| "$date" - ###################### (production-new) War uploaded successfully on elasticbeanstalk ######################"

	date=`date`
	aws elasticbeanstalk create-application-version --region sa-east-1 --application-name "My First Elastic Beanstalk Application" --version-label voyhoy.com-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=voyhoy.com-$version.war
	echo "| "$date" - ###################### (production-new) Application-version created successfully on elasticbeanstal ######################"
fi
