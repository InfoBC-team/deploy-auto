#!/bin/sh

cd /home/vheurope/movelia
git checkout master
git pull origin master
echo "Listo el plugin de movelia"

cd /home/vheurope/vheurope-core
git checkout master
git pull origin master
echo "Listo vheurope-core"

cd /home/vheurope/vheurope-admin
git fetch
git checkout $1
git pull origin $1
echo "Listo vheurope-admin "

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$version" | tr -d '[[:space:]]')

if [ "$1" = "production" ] && [ ! -f "target/vheurope.admin-$version.war" ]; then
	./grailsw clean
	./grailsw war target/vheurope.admin-$version.war
	
	echo "war listo"
	
	aws s3 cp target/vheurope.admin-$version.war s3://elasticbeanstalk-eu-central-1-640270128784/vheurope.admin-$version.war
	aws elasticbeanstalk create-application-version --region eu-central-1 --application-name "production" --version-label vheurope.admin-$version.war --source-bundle S3Bucket=elasticbeanstalk-eu-central-1-640270128784,S3Key=vheurope.admin-$version.war

	echo "[production] Listo todo, solo de ir a AWS y hacer el deploy del war generado"
fi

if [ "$1" = "sandbox" ] && [ ! -f "target/vheurope.admin.sandbox-$version.war" ]; then
	./grailsw clean
	./grailsw -Dgrails.env=test war target/vheurope.admin.sandbox-$version.war
	
	echo "war listo"
	
	aws s3 cp target/vheurope.admin.sandbox-$version.war s3://elasticbeanstalk-eu-central-1-640270128784/vheurope.admin.sandbox-$version.war
	aws elasticbeanstalk create-application-version --region eu-central-1 --application-name "My First Elastic Beanstalk Application" --version-label vheurope.admin.sandbox-$version.war --source-bundle S3Bucket=elasticbeanstalk-eu-central-1-640270128784,S3Key=vheurope.admin.sandbox-$version.war

	echo "[sandbox] Listo todo, solo de ir a AWS y hacer el deploy del war generado"
fi
