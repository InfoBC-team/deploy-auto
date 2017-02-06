#!/bin/sh
echo "starting......"

cd /home/voyhoy/voyhoy-core
git fetch
git checkout new-vh
git pull origin new-vh
date=`date`
echo "| "$date" ###################### core is ready ######################"

if [ "$1" = "full" ]; then

	cd /home/voyhoy/$3
	git checkout $2
	git pull origin $2

	date=`date`
	echo "| "$date" ###################### "$3" is ready ######################"

	version=`git log -n 1 --pretty=format:"%cd-%h" --date=short`

	if [ "$2" = "sandbox"] || ["$2" = "sandbox-new-vh" ] && [ ! -f "target/sandbox-$3-$version.war" ]; then
		./grailsw -Dgrails.env=test war target/sandbox-$3-$version.war
		date=`date`
		echo "| "$date" ###################### war compiled successfully ######################"

		date=`date`
		aws s3 cp target/sandbox-$3-$version.war s3://elasticbeanstalk-us-east-1-640270128784/sandbox-$3-$version.war
		echo "| "$date" ###################### war uploaded successfully on elasticbeanstalk ######################"

		date=`date`
		aws elasticbeanstalk create-application-version --region us-east-1 --application-name voyhoy-admin2 --version-label sandbox-$3-$version.war --source-bundle S3Bucket=elasticbeanstalk-us-east-1-640270128784,S3Key=sandbox-$3-$version.war
		echo "| "$date" ###################### application-version created successfully on elasticbeanstalk ######################"

		eb init voyhoy-admin2 --region us-east-1

		date=`date`
		eb deploy voyhoyAdmin2-env --version sandbox-$3-$version.war
		echo "| "$date" ###################### deploy on elasticbeanstalk successfully ######################"
	fi

	if [ "$2" = "production" ] && [ ! -f "target/$3-$version.war" ]; then
		./grailsw war target/$3-$version.war
		date=`date`
		echo "| "$date" ###################### war compiled successfully ######################"
		
		date=`date`
		aws s3 cp target/$3-$version.war s3://elasticbeanstalk-sa-east-1-640270128784/$3-$version.war
		echo "| "$date" ###################### war uploaded successfully on elasticbeanstalk ######################"

		date=`date`
		aws elasticbeanstalk create-application-version --region sa-east-1 --application-name voyhoyadmin --version-label $3-$version.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=$3-$version.war
		echo "| "$date" ###################### application-version created successfully on elasticbeanstalk ######################"

		eb init voyhoyadmin --region sa-east-1

		date=`date`
		eb deploy voyhoy-admin --version $3-$version.war
		echo "| "$date" ###################### deploy on elasticbeanstalk successfully ######################"
	fi

	date=`date`;
	echo "| "$date" ###################### Repositories voyhoy-core and "$3" ready - branch "$2" - version "$version""

elif [ "$1" = "single" ]; then

	cd /home/voyhoy/$2
	git checkout $3
	git pull origin $3

	date=`date`
	echo "| "$date" ###################### "$2" is ready ######################"

	if [ "$5" = "sandbox" ]; then
		./grailsw -Dgrails.env=test war target/sandbox-$2-$4.war
		date=`date`
		echo "| "$date" ###################### war compiled successfully ######################"

		date=`date`
		aws s3 cp target/sandbox-$2-$4.war s3://elasticbeanstalk-us-east-1-640270128784/sandbox-$2-$4.war
		echo "| "$date" ###################### war uploaded successfully on elasticbeanstalk ######################"

		date=`date`
		aws elasticbeanstalk create-application-version --region sa-east-1 --application-name voyhoy-admin2 --version-label sandbox-$2-$4.war --source-bundle S3Bucket=elasticbeanstalk-us-east-1-640270128784,S3Key=sandbox-$2-$4.war
		echo "| "$date" ###################### application-version created successfully on elasticbeanstalk ######################"

		eb init voyhoy-admin2 --region us-east-1

		date=`date`
		eb deploy voyhoyAdmin2-env --version sandbox-$2-$4.war
		echo "| "$date" ###################### deploy on elasticbeanstalk successfully ######################"
	fi

	if [ "$5" = "production" ]; then
		./grailsw war target/$2-$4.war
		date=`date`
		echo "| "$date" ###################### war compiled successfully ######################"

		date=`date`
		aws s3 cp target/$2-$4.war s3://elasticbeanstalk-sa-east-1-640270128784/$2-$4.war
		echo "| "$date" ###################### war uploaded successfully on elasticbeanstalk ######################"

		date=`date`
		aws elasticbeanstalk create-application-version --region sa-east-1 --application-name voyhoyadmin --version-label $2-$4.war --source-bundle S3Bucket=elasticbeanstalk-sa-east-1-640270128784,S3Key=$2-$4.war
		echo "| "$date" ###################### application-version created successfully on elasticbeanstalk ######################"

		eb init voyhoyadmin --region sa-east-1

		date=`date`
		eb deploy voyhoy-admin --version $2-$4.war
		echo "| "$date" ###################### deploy on elasticbeanstalk successfully ######################"
	fi

fi
