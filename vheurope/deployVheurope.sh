#!/bin/sh

cd /home/vheurope/vheurope-core
git fetch
git checkout $1
git pull origin $1
echo "Listo vheurope-core"

cd /home/vheurope/vheurope-api
git fetch
git checkout $1
git pull origin $1
echo "Listo vheurope-api "

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$version" | tr -d '[[:space:]]')

if [ "$1" = "master" ] && [ ! -f "target/vheurope.api-$version.war" ]; then
	./grailsw clean
	./grailsw war target/vheurope.api-$version.war
	
	echo "war listo"
	
	aws s3 cp target/vheurope.api-$version.war s3://elasticbeanstalk-eu-central-1-640270128784/vheurope.api-$version.war
	aws elasticbeanstalk create-application-version --region eu-central-1 --application-name "production" --version-label vheurope.api-$version.war --source-bundle S3Bucket=elasticbeanstalk-eu-central-1-640270128784,S3Key=vheurope.api-$version.war

	echo "[production] Listo todo, solo de ir a AWS y hacer el deploy del war generado"
fi

if [ "$1" = "sandbox" ] && [ ! -f "target/vheurope.api.sandbox-$version.war" ]; then
	./grailsw clean
	./grailsw -Dgrails.env=test war target/vheurope.api.sandbox-$version.war
	
	echo "war listo"
	
	aws s3 cp target/vheurope.api.sandbox-$version.war s3://elasticbeanstalk-eu-central-1-640270128784/vheurope.api.sandbox-$version.war
	aws elasticbeanstalk create-application-version --region eu-central-1 --application-name "My First Elastic Beanstalk Application" --version-label vheurope.api.sandbox-$version.war --source-bundle S3Bucket=elasticbeanstalk-eu-central-1-640270128784,S3Key=vheurope.api.sandbox-$version.war

	echo "[sandbox] Listo todo, solo de ir a AWS y hacer el deploy del war generado"
fi
