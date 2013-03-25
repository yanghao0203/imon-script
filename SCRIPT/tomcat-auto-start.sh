#!/bin/sh -
#this script is for tomcat auto-start
#root
#chkconfig:35 85 15
#description:tomcat
#/etc/rc.d/init.d/tomcatd

TOMCAT_BIN=$TOMCAT_HOME$/bin
PID=`ps -ef | grep tomcat | grep -v grep | grep -v tmocatd | awk '{print $2}'`  

status(){
	if [ -n $PID ]; then
		echo "tomcat is running~"
		else 
		echo "tomcat is down..."
	fi
} 

start(){
	cd $TOMCAT_BIN
	./startup.sh  > /dev/null 2>&1	      
	echo "done"
}

stop(){
	kill -9 $PID
	echo "done"
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
status)
	status
	;;
restart)
	stop
	start
esac

