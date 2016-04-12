#!/bin/sh
echo "starting......"
./grailsw --version

cd /home/voyhoy/voyhoy-core
git checkout master
git pull origin master
date=`date`
echo "| "$date" ###################### voyhoy-core is ready ######################"

cd /home/voyhoy/lab-grails-app
git checkout $1
git pull origin $1

date=`date`
echo "| "$date" - ###################### lab-grails-app is ready ######################"

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$version" | tr -d '[[:space:]]')

if [ "$1" = "production" ] && [ ! -f "target/voyhoy-$version.war" ]; then
	./grailsw clean
	./grailsw war target/voyhoy-$version.war
	date=`date`
	echo "| "$date" - ###################### (production) War compiled successfully ######################"

	date=`date`
	aws s3 cp target/voyhoy-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/voyhoy-$version.war
	echo "| "$date" - ###################### (production) War uploaded successfully on elasticbeanstalk ######################"

	date=`date`
	aws elasticbeanstalk create-application-version --region sa-east-1 --application-name "My First Elastic Beanstalk Application" --version-label voyhoy-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=voyhoy-$version.war
	echo "| "$date" - ###################### (production) Application-version created successfully on elasticbeanstal ######################"

	# eb use cloneprod-1
	# eb init "My First Elastic Beanstalk Application" --region sa-east-1

	# date=`date`
	# eb deploy cloneprod-1 --version voyhoy-$version.war
	# echo "| "$date" - ###################### (production) Deploy on elasticbeanstalk successfull ######################"
fi

if [ "$1" = "testing" ] && [ ! -f "target/voyhoy-testing-$version.war" ]; then
	./grailsw clean
	./grailsw -Dgrails.env=test war target/voyhoy-testing-$version.war
	date=`date`
	echo "| "$date" - ###################### (testing) War compiled successfully ######################"

	date=`date`
	aws s3 cp target/voyhoy-testing-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/voyhoy-testing-$version.war
	echo "| "$date" - ###################### (testing) War uploaded successfully on elasticbeanstalk ######################"

	date=`date`
	aws elasticbeanstalk create-application-version --region sa-east-1 --application-name "My First Elastic Beanstalk Application" --version-label voyhoy-testing-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=voyhoy-testing-$version.war
	echo "| "$date" - ###################### (testing) Application-version created successfully on elasticbeanstal ######################"

	# eb use voyhoyrocks
	# eb init "My First Elastic Beanstalk Application" --region sa-east-1

	# date=`date`
	# eb deploy voyhoyrocks --version voyhoy-testing-2015-12-30-79970c5-72204.war
	# echo "| "$date" - ###################### (testing) Deploy on elasticbeanstalk successfull ######################"
fi