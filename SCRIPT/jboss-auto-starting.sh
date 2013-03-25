#!/bin/sh -
#this script is for jboss and hornetq auto-start
#root
#chkconfig:35 85 15
#description:jboss
#/etc/rc.d/init.d/jbossd

JBOSS_BIN=$JBOSS_HOME/bin
PID1=`ps -ef | grep jboss | grep -v hornetq | grep -v grep | grep -v jbossd | sed -n 1p | awk '{print $2}'`
PID2=`ps -ef | grep jboss | grep hornetq | grep -v grep | sed -n 1p | awk '{print $2}'`   
#这边有个Bug，由于脚本名称就是jbossd，这边会导致PID2的值出现该脚本的pid，这边使用grep -v jbossd过滤掉了
STATUS=1

status(){

	if [ -n "$PID2" && -n "$PID1" ]; then
		echo "Hornetq and JBOSS are all running~"
		elif [[ -n "$PID2" && -z "$PID1" ]]; then
	echo "Hornetq is running~"
	else "JBOSS is running~"
	fi
}

start(){
	cd  $JBOSS_BIN
	if [ -z $PID2 ] ; then
	
	echo "Hornetq is starting..."
	./hornetq.sh  > /dev/null  2>&1

        until tail -n 1  "$JBOSS_HOME/server/hornetq/log/boot.log" | grep "Removing bootstrap log handlers" > /dev/null
         do
                sleep 2
        done
    else
    echo "Hornetq is already running~"
    fi

        echo "JBOSS is starting..."
        ./certus.sh  > /dev/null 2>&1
	echo "done"

}

stop(){
	echo "this opration only stop jboss Process!!"
	kill -9  $PID1
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