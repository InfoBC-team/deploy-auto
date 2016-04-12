#!/bin/sh

cd /home/voyhoy/voyhoy-core
git checkout master
git pull origin master
echo "###################### core is ready ######################"

cd /home/voyhoy/lab-grails-app
git fetch
git checkout $1
git pull origin $1
echo "###################### lab-grails-app is ready ######################"

echo "###################### compiling the war ######################"

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$1-$version" | tr -d '[[:space:]]')

if [ ! -f "target/pivotal-$1-$version.war" ]; then
	./grailsw clean
	./grailsw -Dgrails.env=test war target/pivotal-$1-$version.war
	echo "war done!"
	cf push voyhoy-infobc -p target/pivotal-$1-$version.war
	echo "###################### Full compiled and deployed with version "$1-$version" ######################"
fi

date=`date`;
echo "Repositories voyhoy-core and lab-grails-app ready - version "$1-$version" - date "$date""
