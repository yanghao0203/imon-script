#!/bin/sh
#==========================================================================
#title=update.sh
#written by yanghao
#this shellscript is written for ims-system updating.
#本脚本可用于更新当前服务器，也可以用于更新远程服务器，详见：show_help
#运行此脚本前先手动修改相关配置文件,如：
#java子系统中的conf.properties
#C程序子系统中的vm.cfg
#==========================================================================

#Environment Variables
IMS_PATH=/usr/local/ims                            #终端程序目录
UPLOAD_PATH=/home/ims/update                       #新包目录
GUI_PATH="$JBOSS_HOME/server/default/deploy"       #GUI包目录
GUI_BAKPATH="$JBOSS_HOME/server/default/backup"    #GUI包备份目录
SUBSYSTEM_PATH="$JBOSS_HOME/server/all/farm"       #子系统包目录
SUBSYSTEM_BAKPATH="$JBOSS_HOME/server/all/backup"  #子系统包备份目录
ESB_PATH=$MULE_HOME                                #ESB程序目录
ESB_BAKPATH="$MULE_HOME/backup"                    #ESB包备份目录
CON_BAKPATH=/usr/local/ims/backup                  #终端程序备份目录
PID=""                                             #进程PID预设变量
DATETIME=`date +%Y%m%d`

#判断scp后跟随的参数（参数为主机名），参数为空时执行doCheck
doChoose()
{  
	if [ $# = 0 ] ; do
		doCheck
	 else
	    echo -n "Servers waiting to update are "
	    echo $*
	    echo -n "Please check the name of these Servers is right[yes|no]:"
	    read answer 
	    if [ $answer = xyes ] ; do 
	    	while [ $# != 0 ]; do
	    		ssh root@$1 " /home/ims/update/update.sh "
	    		shift
	    	   done
	     else
	        show_help  
	     	exit
	    fi
   	 fi
}


doCheck()
{		
case "$HOSTNAME" in
    ups*)
		doUpdateGUI_UPS
    ;;
    re*)
		doUpdateReceive
    ;;
    sc*)	
   	    doUpdateScheduler
    ;;
    ac*)	
	    doUpdateAC
	;;	
	vd*)
		doUpdateVD
    ;;
    vl*)
		doUpdateVL
    ;;
    ep*)	
   	    doUpdateEpgtracer
    ;;
    ke*)	
	    doUpdateKettle
	;;
    es*)
        doUpateMule
    ;;
    ssg*)
        doUpdateSSG
	;;
	ssi*)
        doUpdateSSI
	;;
	srs*)
        doUpdateSRS
	;;
	vcrs*)
        doUpdateVCRS
	;;
	multistreamer*)
        doUpdateMulStr
	;;
	*)
        echo "This server do'nt need to update!"
	;;
esac
}



#GUI和UPS更新
doUpdateGUI_UPS()
{
			echo -n "make sure the file %%conf.properties%% is update[yes|no]:"
			read word
			if [ x$word == xyes ]; then
					echo "update starting..."
				else 
				exit
			fi
            PID=`ps -ef | grep jboss | grep -v grep | awk '{print $2}'`
			if [ -n "$PID" ]; then                        #这里由于是引用PID变量，需要用双引号
				echo 'begin to kill JMS id:'
				echo $PID
			    kill -9 $PID
			else 
			    echo "JMS is no running..."
			fi
			
			if [ -d "$UPLOAD_PATH/JAVA" ]; then 
			echo ""
             
            #清除jboss和hornetq缓存数据
            echo "Clear cached data..."
            rm -rf  $JBOSS_HOME/server/default/tmp
			rm -rf  $JBOSS_HOME/server/default/work
#
			#备份旧版本包
			echo ""
#            echo "Now backup the old packages..."
			echo ""
            if [ -d "$GUI_BAKPATH/$DATETIME" ]; then 
 #               echo "Backup path is already exist,now backup the old packages..."
				#( ls -l $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;/bin/cp --backup=numbered \$GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' ) | xargs sh -x | echo "Packages are all backuped successfully~"
                /bin/cp --backup=numbered $GUI_PATH/imon*  $GUI_BAKPATH/$DATETIME/  
                /bin/cp --backup=numbered $GUI_PATH/Qms.war  $GUI_BAKPATH/$DATETIME/ 
					

#				echo "**           Packages are all backuped successfully~             **"

            else
                mkdir -p $GUI_BAKPATH/$DATETIME/
				#ll $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;cp $GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' | xargs sh -x | echo "Packages are all backuped successfully~"
                cp $GUI_PATH/imon*  $GUI_BAKPATH/$DATETIME/ 
                cp $GUI_PATH/Qms.war  $GUI_BAKPATH/$DATETIME/ 
           
#				echo "**            Packages are all backuped successfully~             **"

			fi	
						
			#上传新包并替换
#            echo "Now replace the old packages..."
            /bin/cp $UPLOAD_PATH/JAVA/* $GUI_PATH/ 

#			echo "**              Packages are all updated successfully~            **"

			else 
			echo ""
			echo "Packetages for update not found,please check."
			echo ""
			exit
			fi

			#start jboss
			echo "Starting JMS..."
			cd $JBOSS_HOME/bin && ./certus.sh
			#log
			echo "Check logs with following cmds..."
			echo "tail -f /usr/local/ims/jboss-6.0.0.Final/server/default/log/boot.log"
			echo "tail -f /usr/local/ims/jboss-6.0.0.Final/server/default/log/server.log"
}

#Subsystem
doUpdateSubsystem()
{
			echo -n "make sure the file %%conf.properties%% is update[yes|no]:"
			read word
			if [ x$word == xyes ]; then
					echo "update starting..."
				else 
				exit
			fi

            PID=`ps -ef | grep jboss | grep -v grep | sed -n 2p| awk '{print $2}'`
			if [ -n "$PID" ]; then                        #这里由于是引用PID变量，需要用双引号
				echo 'begin to kill JMS id:'
				echo $PID
			    ps -ef | grep jboss | grep -v grep | awk '{print $2}' | xargs kill -9 
			else 
			    echo "JMS is no running..."
			fi
			
			if [ -d "$UPLOAD_PATH/JAVA" ]; then 
			echo ""
			#清除缓存数据           
            echo "Clear cached data..."
            rm -rf  $JBOSS_HOME/server/all/tmp 
			rm -rf  $JBOSS_HOME/server/all/work
			
			#备份旧版本包
			echo ""
 #           echo "Now backup the old packages..."
#			echo ""
            if [ -d "$SUBSYSTEM_BAKPATH/$DATETIME" ]; then 
 #               echo "Backup path is already exist,now backup the old packages..."
				#( ls -l $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;/bin/cp --backup=numbered \$GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' ) | xargs sh -x | echo "Packages are all backuped successfully~"
				#echo "**            Packages are all backuped successfully~             **"
            else
                mkdir -p $SUBSYSTEM_BAKPATH/$DATETIME/
				#ll $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;cp $GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' | xargs sh -x | echo "Packages are all backuped successfully~"
                cp $SUBSYSTEM_PATH/*  $SUBSYSTEM_BAKPATH/$DATETIME/ 
           
#				echo "**            Packages are all backuped successfully~             **"

			fi	
						
			#上传新包并替换
#           echo "Now replace the old packages..."
            cp $UPLOAD_PATH/JAVA/* $SUBSYSTEM_PATH/ 
#			echo $UPLOAD_PATH/JAVA/
#			echo $SUBSYSTEM_PATH/
#			echo "**              Packages are all updated successfully~            **"


			else 
			echo ""
			echo "Packetages for update not found,please check."
			echo ""
			exit
			fi

			#start jboss
			echo "Starting JMS..."
			cd $JBOSS_HOME/bin && ./cluster.sh	

			echo "Check logs with following cmds..."
			echo "tail -f /usr/local/ims/jboss-6.0.0.Final/server/all/log/boot.log"
			echo "tail -f /usr/local/ims/jboss-6.0.0.Final/server/all/log/server.log"
}
}

#Receive
doUpdateReceive()
{
	doUpdateSubsystem
}

#Scheduler
doUpdateScheduler()
{
	doUpdateSubsystem
}

#approvalchecker
doUpdateAC()
{
	doUpdateSubsystem
}

#violationdetector
doUpdateVD()
{
	doUpdateSubsystem
}

#violationlocator
doUpdateVL()
{
	doUpdateSubsystem
}

#epgtracer
doUpdateEpgtracer()
{
	doUpdateSubsystem
}

#kettle
doUpdateKettle()
{
	doUpdateSubsystem
}

#ESB更新
doUpateMule()
{
        PID=`ps -ef | grep mule | grep -v grep | awk '{print $2}' | sed -n 1p` 
		
		if [ -n "$PID" ]; then
			echo 'begin to kill mule id:'
			echo $PID
			ps -ef | grep mule | grep -v grep | awk '{print $2}' | xargs kill -9 
		else 
			echo "mule is no running..."
		fi

		if [ -d "$UPLOAD_PATH/JAVA/" ]; then 
#			echo ""
#			echo "ESB update starting..."
#			echo ""
            #备份旧版本文件包
#			echo ""
#			echo "Now backup the old packages..."
#			echo ""
			if [ -d "$ESB_BAKPATH/$DATETIME" ]; then 			
#				echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT  $ESB_BAKPATH/$DATETIME/ 
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/mule-module-remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/mule-transport-ejb3-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			else 
			    mkdir -p "$ESB_BAKPATH/$DATETIME"
				/bin/cp -r $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT  $ESB_BAKPATH/$DATETIME/ 
			    /bin/cp $ESB_PATH/lib/mule/mule-module-remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
			    /bin/cp $ESB_PATH/lib/mule/mule-transport-ejb3-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
			    /bin/cp $ESB_PATH/lib/mule/remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			fi
			
            #上传新包并替换
#			echo ""
 #           echo "Now replace the old packages..."
#			echo ""
    	    cp $UPLOAD_PATH/JAVA/*.jar $ESB_PATH/lib/mule/ 
			#加入判断下是否成功备份
			rm -rf $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/* 

			cp $UPLOAD_PATH/JAVA/ups-esb-scheduler-1.0-SNAPSHOT.zip $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/ && /usr/bin/unzip -q -d $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/ $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/*.zip 
			sleep 3 
			#替换配置文件
			/bin/cp /$ESB_BAKPATH/$DATETIME/ups-esb-scheduler-1.0-SNAPSHOT/classes/scheduler.properties $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/classes/ 
#			echo ""
#			echo "**              Packages are all updated successfully~                **"
#			echo ""
			
		else 
			echo ""
			echo "**         Packetages for update not found,please check.          **"
			echo ""
			exit
		fi
		cd $ESB_PATH/bin && ./certus.sh
}


doUpdateSSG()
{
		exit            
}

#SRS更新
doUpdateSRS()
{
		echo -n "make sure configure the file %%vm.cfg%%[yes|no]:"
		read word
		if [ x$word == xyes ]; then
				echo "update starting..."
			else 
				exit
		fi

		#关闭srs进程
		PID=`ps -ef |grep srs |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to stop SRS service:'
		#	echo $PID
		#	kill -9 $PID
		service srs stop
		else 
			echo "srs is no running..."
		fi
		
		if [ -d "$UPLOAD_PATH"/SRS ]; then 
#			echo ""
#           echo "SRS update starting..."
#			echo ""
		#旧版本文件备份
#			echo ""
#           echo "Now backup the old packages..."
#			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
#			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/srs $CON_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/srs $CON_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			fi
			
			#新包上传并替换
#			echo ""
 #           echo "Now replace the old packages..."
#			echo ""
			rm -rf $IMS_PATH/srs
			rm -rf $IMS_PATH/SRS*
#			Srs_Pgt=`ls -lrt $UPLOAD_PATH/SRS/ | sed -n '$p' | awk '{print $9}'`  #确保使用的更新包为最新的包
			cp $UPLOAD_PATH/SRS/SRS*.tar.gz $IMS_PATH/ 
			tar -zxvf $IMS_PATH/SRS*.tar.gz  -C $IMS_PATH/
			rm -rf $IMS_PATH/SRS*.tar.gz   
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/srs/bin/vm.cfg $IMS_PATH/srs/bin/ 
			/bin/cp $CON_BAKPATH/$DATETIME/srs/bin/svc.conf $IMS_PATH/srs/bin/ 
#			echo ""
#			echo "**              Packages are all updated successfully~                **"
 #           echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
#			echo ""
			
		else 
			echo ""
			echo "**         Packetages for update not found,please check.          **"
			echo ""
			exit
		fi	

		echo "Starting SRS service..."
		service srs start
}

#SSI更新
doUpdateSSI()
{
		echo -n "make sure configure the file %%vm.cfg%%[yes|no]:"
		read word
		if [ x$word == xyes ]; then
				echo "update starting..."
			else 
				exit
		fi

		#关闭SSI进程
		PID=`ps -ef |grep 'ssi -d' |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to stop ssi service...'
			#echo $PID
			#kill -9 $PID
			service ssi stop
		else 
			echo "ssi is no running..."
		fi
		
		if [ -d $UPLOAD_PATH/SSI* ]; then 
			echo ""
            echo "SSI update starting..."
			echo ""
		#旧版本文件备份
#			echo ""
#            echo "Now backup the old packages..."
#			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
#			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/ssi $CON_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/ssi $CON_BAKPATH/$DATETIME/ 
#				echo ""
#			    echo "**           Packages are all backuped successfully~              **"
#				echo ""
			fi
			
			#新包上传并替换
#			echo ""
#            echo "Now replace the old packages..."
#			echo ""
			rm -rf $IMS_PATH/ssi* 
			Ssi_Pgt=`ls -lrt $UPLOAD_PATH/SSI/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/SSI/$Ssi_Pgt $IMS_PATH/
			tar -zxvf $IMS_PATH/ssi*.tar.gz  -C $IMS_PATH/ 
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/ssi/bin/vm.cfg $IMS_PATH/ssi/bin/ 
			/bin/cp $CON_BAKPATH/$DATETIME/ssi/bin/svc.conf $IMS_PATH/ssi/bin 
#			echo ""
#			echo "**              Packages are all updated successfully~                **"
 #           echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
#			echo ""
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**         Packetages for update not found,please check.          **"
			echo "********************************************************************"
			echo ""
			exit
		fi	

		echo "Starting SSI service..."
		service ssi start
}

#Multistreamer更新
doUpdateMulStr()
{
		echo -n "make sure configure the file %%vm.cfg%%[yes|no]:"
		read word
		if [ x$word == xyes ]; then
				echo "update starting..."
			else 
				exit
		fi

		#关闭JointStreamer进程
		PID=`ps -ef |grep JointStreamer |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to stop multistreamer service...'
		#	echo $PID
		#	kill -9 $PID
		service multistreamer stop
		else 
			echo "multistreamer is no running..."
		fi

			
		if [ -d $UPLOAD_PATH/multistreamer ]; then 
#			echo ""
 #           echo "Multistreamer update starting..."
#			echo ""
			#旧版本文件备份
#			echo ""
 #           echo "Now backup the old packages..."
#			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
#			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/multistreamer $CON_BAKPATH/$DATETIME/ 
#				echo ""
#				echo "********************************************************************"
#			    echo "**           Packages are all backuped successfully~              **"
#				echo "********************************************************************"
#				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/multistreamer $CON_BAKPATH/$DATETIME/ 
#				echo ""
#				echo "********************************************************************"
#			    echo "**           Packages are all backuped successfully~              **"
#				echo "********************************************************************"
#				echo ""
			fi
			
			#新包上传并替换
#			echo ""
 #           echo "Now replace the old packages..."
#			echo ""
			rm -rf $IMS_PATH/multistreamer*
#			Mul_Pgt=`ls -lrt $UPLOAD_PATH/multiStreamer/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/multistreamer/* $IMS_PATH/
			tar -zxvf $IMS_PATH/multistreamer*.tar.gz  -C $IMS_PATH/ 
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/multistreamer/bin/vm.cfg $IMS_PATH/multistreamer/bin/ 
			/bin/cp $CON_BAKPATH/$DATETIME/multistreamer/bin/svc.conf $IMS_PATH/multistreamer/bin 
#			echo ""
#			echo "************************************************************************"
#			echo "**              Packages are all updated successfully~                **"
#           echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
#			echo "************************************************************************"
#			echo ""
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**         Packetages for update not found,please check.          **"
			echo "********************************************************************"
			echo ""
			exit
		fi	

		echo "Starting multistreamer service..."
		service multistreamer start
}

#VCRS更新
doUpdateVCRS()
{
		echo -n "make sure the file %%vm.cfg%% is update[yes|no]:"
		read word
		if [ x$word == xyes ]; then
				echo "update starting..."
			else 
				exit
		fi

		#关闭VCRS进程
		PID=`ps -ef |grep vcrs |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to kill vcrs id:'
			echo $PID
			kill -9 $PID
		else 
			echo "vcrs is no running..."
		fi
		
		if [ -d $UPLOAD_PATH/VCRS* ]; then 
#			echo ""
 #           echo "VCRS update starting..."
#			echo ""
		#旧版本文件备份
#			echo ""
 #           echo "Now backup the old packages..."
#			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
#			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/VCRS* $CON_BAKPATH/$DATETIME/ 
#				echo ""
#				echo "********************************************************************"
#			    echo "**           Packages are all backuped successfully~              **"
#				echo "********************************************************************"
#				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/VCRS* $CON_BAKPATH/$DATETIME/ 
#				echo ""
#				echo "********************************************************************"
#			    echo "**           Packages are all backuped successfully~              **"
#				echo "********************************************************************"
#				echo ""
			fi
			
			#新包上传并替换
#			echo ""
 #           echo "Now replace the old packages..."
#			echo ""
			rm -rf $IMS_PATH/VCRS* 
			rm -rf $IMS_PATH/vcrs*
#			Vcrs_Pgt=`ls -lrt $UPLOAD_PATH/VCRS/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/VCRS/* $IMS_PATH/ 
			tar -zxvf $IMS_PATH/VCRS*.tar.gz  -C $IMS_PATH/  
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/VCRS*/bin/vm.cfg $IMS_PATH/VCRS*/bin/
			/bin/cp $CON_BAKPATH/$DATETIME/VCRS*/bin/svc.conf $IMS_PATH/VCRS*/bin 
#			echo ""
#			echo "************************************************************************"
#			echo "**              Packages are all updated successfully~                **"
 #           echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
#			echo "************************************************************************"
#			echo ""

		else 
			echo ""
			echo "********************************************************************"
			echo "**         Packetages for update not found,please check.          **"
			echo "********************************************************************"
			echo ""
			exit
		fi	
}

#帮助文档
show_help()
{
   echo "User's Manual:"
   echo "Update local server , just execute like this  './update.sh' or '/home/ims/update/update.sh'  "
   echo "Update remote servers , just  execute like this './update.sh server1 server2 server3 ...' or '/home/ims/update/update.sh server1 server2 server3 ...' "
}

doChoose
