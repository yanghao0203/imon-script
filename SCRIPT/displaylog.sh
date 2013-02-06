#!/bin/sh 
#displaylog.sh 
jbosslog=`tail -20f /usr/local/ims/jboss-6.0.0-all-in-one/server/default/log/server.log`

mulelog=`tail -20f /usr/local/ims/mule-standalone-3.3-M2/logs/mule-app-ups-esb-scheduler-1.0-SNAPSHOT.log`

srslog=`tail -20f /var/log/srs.log`

ssilog=`tail -20f /var/log/ssi.log`

ssglog=`tail -20f /var/streaming/logs/StreamingServer.log`

mslog=`tail -20f /var/log/JointStreamer.log`

doDisjboss()  {
    $jbosslog

}	

doDismule()   {
    $mulelog 
}

doDisrs()    {
    $srslog
}

doDisssi()   {
    $ssilog
}

doDisssg()   {
    $ssglog
}

doDisssg()   {
    $mslog
}

show_help () {
	cat <<END

Usage: $0  <command> 
 
  command options: jboss|mule|srs|ssi|ssg|ms|help

END
	return
}

if [ $# -eq 0 ]; then
	show_help
	exit 1
else
	COMMAND="$1"; shift
fi	 
	
case "$COMMAND" in
    jboss)
       doDisjboss
    ;;
    mule)
       doDismule
    ;;
    srs)	
   	    doDisrs
    ;;
    ssg)	
	    doDisssg
	;;	
   help | ?)
            show_help
        ;;
     * )
            echo "请输入正确的参数"
            show_help
	;;
esac
