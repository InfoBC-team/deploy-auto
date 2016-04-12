#!/bin/sh

cd /home/vheurope/voyhoy-core
git checkout master
git pull origin master
echo "Listo el core"

cd /home/vheurope/lab-grails-app
git fetch
git checkout $1
git pull origin $1
echo "Listo bajar todo para lab-grails-app en la rama "$1""

lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
tiempo=`date +"%k%M%S"`;
version=$lastCommit"-"$tiempo

version=$(echo "$1-$version" | tr -d '[[:space:]]')

if [ ! -f "target/vheurope-$1-$version.war" ]; then
	./grailsw clean
	./grailsw -Dgrails.env=test war target/vheurope-$1-$version.war
	echo "war listo"
	cf push vheurope -p target/vheurope-$1-$version.war
	date=`date`;
	echo "Se compiló todo exitosamente - "$date""
fi
