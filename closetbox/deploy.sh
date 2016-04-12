#!/bin/sh
./grailsw--version

if [ "$1" = "full" ]; then

	cd /home/orlando/closetbox-core
	git checkout develop
	git pull origin develop
	echo "-------------------------------------- core is ready --------------------------------------"

	cd /home/orlando/$3
	git checkout $2
	git pull origin $2
	echo "-------------------------------------- "$3" is ready --------------------------------------"

	echo "-------------------------------------- compiling the war --------------------------------------"

	# version=`grep "app.version" application.properties | grep -o "=.*" | sed 's/^.//'`
	version=`git log -n 1 --pretty=format:"%cd-%h" --date=short`

	if [ "$2" = "sandbox" ] && [ ! -f "target/sandbox-$version.war" ]; then
		./grailsw -Dgrails.env=sandbox war target/sandbox-$version.war
		echo "war done!"
		cf stop $3-sandbox
		cf push $3-sandbox -p target/sandbox-$version.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $3-sandbox
		echo "-------------------------------------- Full compiled with branch "$2" and version "$version" --------------------------------------"
	fi

	if [ "$2" = "production" ] && [ ! -f "target/$3-$version.war" ]; then
		./grailsw war target/$3-$version.war
		echo "war done!"
		cf stop $3
		cf push $3 -p target/$3-$version.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $3
		echo "-------------------------------------- Full compiled with branch "$2" and version "$version" --------------------------------------"
	fi

	date=`date`;
	echo "Repositories closetbox-core and "$3" ready - branch "$2" - version "$version" - date "$date""

elif [ "$1" = "single" ]; then

	cd /home/orlando/$2

	if [ "$4" = "sandbox" ]; then
		cf stop $2-sandbox
		cf push $2-sandbox -p target/sandbox-$3.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $2-sandbox
		date=`date`;
		echo "-------------------------------------- Full compiled with sandbox version "$3" - date "$date" --------------------------------------"
	fi

	if [ "$4" = "production" ]; then
		cf stop $2
		cf push $2 -p target/$2-$3.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $2
		date=`date`;
		echo "-------------------------------------- Full compiled with production version "$3" - date "$date" --------------------------------------"
	fi

elif [ "$1" = "singleWar" ]; then

	cd /home/orlando/closetbox-core
	git checkout develop
	git pull origin develop
	echo "-------------------------------------- core is ready --------------------------------------"

	cd /home/orlando/$2
	git checkout develop
	git pull origin develop
	echo "-------------------------------------- "$2" is ready --------------------------------------"

	echo "-------------------------------------- compiling the war --------------------------------------"

	lastCommit=`git log -n 1 --pretty=format:"%cd-%h" --date=short`;
	tiempo=`date +"%k%M%S"`;
	version=$lastCommit"-"$tiempo

	version=$(echo "$version" | tr -d '[[:space:]]')

	echo "--------------------------------------"$lastCommit"--------------------------------------"
	echo "--------------------------------------"$tiempo"--------------------------------------"
	echo "--------------------------------------"$version"--------------------------------------"

	if [ "$3" = "sandbox" ] && [ ! -f "target/sandbox-$version.war" ]; then

		./grailsw -Dgrails.env=sandbox war target/sandbox-$version.war
		echo "war done!"
		cf stop $2-sandbox
		cf push $2-sandbox -p target/sandbox-$version.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $2-sandbox
		echo "-------------------------------------- Full compiled manual deploy sandbox war with version "$version" --------------------------------------"
	fi

	if [ "$3" = "production" ] && [ ! -f "target/$2-$version.war" ]; then
		./grailsw war target/$2-$version.war
		echo "war done!"
		cf stop $2
		cf push $2 -p target/$2-$version.war -b https://orlandobcrra:obcp2210@github.com/closetbox/closetbox-java-buildpack.git --no-start
		cf start $2
		echo "-------------------------------------- Full compiled manual deploy production war with version "$version" --------------------------------------"
	fi

	date=`date`;
	echo "Repositories closetbox-core and "$2" ready - env "$3" - version "$version" - date "$date""
fi
