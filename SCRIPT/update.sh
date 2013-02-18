#!/bin/sh
#title=onlineupdate.sh
#this shellscript is written for ims-system updating.
IMS_PATH=/usr/local/ims                            #终端程序目录
UPLOAD_PATH=/home/ims/update                       #新包目录
GUI_PATH="$JBOSS_HOME/server/default/deploy"       #GUI包目录
GUI_BAKPATH="$JBOSS_HOME/server/default/backup"    #GUI包备份目录
ESB_PATH=$MULE_HOME                                #ESB程序目录
ESB_BAKPATH="$MULE_HOME/backup"                    #ESB包备份目录
CON_BAKPATH=/usr/local/ims/backup                  #终端程序备份目录
PID=""                                             #进程PID预设变量

DATETIME=`date +%Y%m%d`

doChoose()
{
		echo ""
		echo "********************************************************************"
		echo "**                                                                **"
		echo "**                   1.GUI and UPS update                         **"
		echo "**                   2.ESB update                                 **"
		echo "**                   3.SSG update                                 **"
		echo "**                   4.SRS update                                 **"
		echo "**                   5.SSI update                                 **"
		echo "**                   6.Multistreamer update                       **"
		echo "**                   7.VCRS update                                **"
		echo "**                   8.Exit                                       **"
		echo "**                   9.Help                                       **"
		echo "**                                                                **"
		echo "********************************************************************"
		echo -n "Please choose the subsystem number(like 1): "
read NUM
		
case "$NUM" in
    1)
		doUpdateGUI_UPS
    ;;
    2)
		doUpateMule
    ;;
    3)	
   	    doUpdateSSG
    ;;
    4)	
	    doUpdateSRS
	;;	
	5)
		doUpdateSSI
    ;;
    6)
		doUpdateMulStr
    ;;
    7)	
   	    doUpdateVCRS
    ;;
    8)	
	    exit
	;;
    9)
        show_help
    ;;
    *)
        show_help
	;;
esac
}


#GUI和UPS更新
doUpdateGUI_UPS()
{
            PID=`ps -ef | grep jboss | grep -v hornetq | grep -v grep | awk '{print $2}'`
			if [ -n "$PID" ]; then                        #这里由于是引用PID变量，需要用双引号
				echo 'begin to kill JMS id:'
				echo $PID
			    kill -9 $PID
			else 
			    echo "JMS is no running..."
			fi
			
			if [ -d "$UPLOAD_PATH/JAVA/one-build" ]; then 
			echo ""
            echo "GUI and UPS update starting..."

            rm -rf  $JBOSS_HOME/server/default/tmp/* 
			rm -rf  $JBOSS_HOME/server/default/work/*
			
#备份旧版本包
			echo ""
            echo "Now backup the old packages..."
			echo ""
            if [ -d "$GUI_BAKPATH/$DATETIME" ]; then 
                echo "Backup path is already exist,now backup the old packages..."
				#( ls -l $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;/bin/cp --backup=numbered \$GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' ) | xargs sh -x | echo "Packages are all backuped successfully~"
                /bin/cp --backup=numbered $GUI_PATH/imon*  $GUI_BAKPATH/$DATETIME/  & sleep 3
                /bin/cp --backup=numbered $GUI_PATH/Qms.war  $GUI_BAKPATH/$DATETIME/  & sleep 1
                /bin/cp --backup=numbered $GUI_PATH/Scheduler.war  $GUI_BAKPATH/$DATETIME/  & sleep 1
                /bin/cp --backup=numbered $GUI_PATH/receiver.war  $GUI_BAKPATH/$DATETIME/  & sleep 1
					
				echo ""
                echo "********************************************************************"
				echo "**                                                                **"
				echo "**            Packages are all backuped successfully~             **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
            else
                mkdir -p $GUI_BAKPATH/$DATETIME/
				#ll $UPLOAD_PATH/JAVA/one-build/ | awk '{print $9}' | grep -v ^$ | sed 's;^;cp $GUI_PATH/;' |  sed 's;$; $GUI_BAKPATH/$DATETIME/ ;' | xargs sh -x | echo "Packages are all backuped successfully~"
                cp $GUI_PATH/imon*  $GUI_BAKPATH/$DATETIME/ & sleep 3
                cp $GUI_PATH/Qms.war  $GUI_BAKPATH/$DATETIME/ & sleep 1
                cp $GUI_PATH/Scheduler.war  $GUI_BAKPATH/$DATETIME/  & sleep 1
                cp $GUI_PATH/receiver.war  $GUI_BAKPATH/$DATETIME/  & sleep 1
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
				echo "**            Packages are all backuped successfully~             **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi	
						
#上传新包并替换
            echo "Now replace the old packages..."
            cp $UPLOAD_PATH/JAVA/one-build/* $GUI_PATH/  & sleep 6
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**              Packages are all updated successfully~            **"
            echo "**       Now please configure the file %%conf.properties%%        **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			sleep 2
			doChoose
		
			else 
			echo ""
			echo "Packetages for update not found,please check."
			echo ""
			exit
			fi
			
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

		if [ -d "$UPLOAD_PATH/JAVA/MULE-ESB" ]; then 
			echo ""
			echo "ESB update starting..."
			echo ""
#备份旧版本文件包
			echo ""
			echo "Now backup the old packages..."
			echo ""
			if [ -d "$ESB_BAKPATH/$DATETIME" ]; then 			
				echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT  $ESB_BAKPATH/$DATETIME/ & sleep 2
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/mule-module-remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/mule-transport-ejb3-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1
				/bin/cp --backup=numbered  $ESB_PATH/lib/mule/remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			else 
			    mkdir -p "$ESB_BAKPATH/$DATETIME"
				/bin/cp -r $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT  $ESB_BAKPATH/$DATETIME/ & sleep 2
			    /bin/cp $ESB_PATH/lib/mule/mule-module-remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1 
			    /bin/cp $ESB_PATH/lib/mule/mule-transport-ejb3-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1
			    /bin/cp $ESB_PATH/lib/mule/remote-1.0-SNAPSHOT.jar $ESB_BAKPATH/$DATETIME/ & sleep 1
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi
			
#上传新包并替换
			echo ""
            echo "Now replace the old packages..."
			echo ""
    	    cp $UPLOAD_PATH/JAVA/MULE-ESB/*.jar $ESB_PATH/lib/mule/  & sleep 1
			#加入判断下是否成功备份
			rm -rf $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/*  & sleep 2
			cp $UPLOAD_PATH/JAVA/MULE-ESB/ups-esb-scheduler-1.0-SNAPSHOT.zip $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/ && /usr/bin/unzip -q -d $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/ $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/*.zip 
			sleep 3 
			#替换配置文件
			/bin/cp /$ESB_BAKPATH/$DATETIME/ups-esb-scheduler-1.0-SNAPSHOT/classes/scheduler.properties $ESB_PATH/apps/ups-esb-scheduler-1.0-SNAPSHOT/classes/ 
			echo ""
			echo "************************************************************************"
			echo "**                                                                    **"
			echo "**              Packages are all updated successfully~                **"
            echo "**Now please make sure the file %%scheduler.properties%% is up_to_date**"
			echo "**                                                                    **"
			echo "************************************************************************"
			echo ""
			sleep 2
			doChoose
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**         Packetages for update not found,please check.          **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			exit
		fi
		
}


doUpdateSSG()
{
		exit            
}

#SRS更新
doUpdateSRS()
{
		#关闭srs进程
		PID=`ps -ef |grep srs |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to kill srs id:'
			echo $PID
			kill -9 $PID
		else 
			echo "srs is no running..."
		fi
		
		if [ -d "$UPLOAD_PATH"/SRS ]; then 
			echo ""
            echo "SRS update starting..."
			echo ""
		#旧版本文件备份
			echo ""
            echo "Now backup the old packages..."
			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/srs $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/srs $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi
			
#新包上传并替换
			echo ""
            echo "Now replace the old packages..."
			echo ""
			rm -rf $IMS_PATH/srs
			rm -rf $IMS_PATH/SRS*
			Srs_Pgt=`ls -lrt $UPLOAD_PATH/SRS/ | sed -n '$p' | awk '{print $9}'`  #确保使用的更新包为最新的包
			cp $UPLOAD_PATH/SRS/$Srs_Pgt $IMS_PATH/ 
			tar -zxvf $IMS_PATH/SRS*.tar.gz  -C $IMS_PATH/
			rm -rf $IMS_PATH/SRS*.tar.gz   
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/srs/bin/vm.cfg $IMS_PATH/srs/bin/ 
			/bin/cp $CON_BAKPATH/$DATETIME/srs/bin/svc.conf $IMS_PATH/srs/bin/ 
			echo ""
			echo "************************************************************************"
			echo "**                                                                    **"
			echo "**              Packages are all updated successfully~                **"
            echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
			echo "**                                                                    **"
			echo "************************************************************************"
			echo ""
			sleep 2
			doChoose
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**         Packetages for update not found,please check.          **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			exit
		fi	
}

#SSI更新
doUpdateSSI()
{
		#关闭SSI进程
		PID=`ps -ef |grep ssi |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to ssi kettle id:'
			echo $PID
			kill -9 $PID
		else 
			echo "ssi is no running..."
		fi
		
		if [ -d $UPLOAD_PATH/SSI* ]; then 
			echo ""
            echo "SSI update starting..."
			echo ""
#旧版本文件备份
			echo ""
            echo "Now backup the old packages..."
			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/ssi $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/ssi $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi
			
#新包上传并替换
			echo ""
            echo "Now replace the old packages..."
			echo ""
			rm -rf $IMS_PATH/[ssiSSi]* & sleep 2
			Ssi_Pgt=`ls -lrt $UPLOAD_PATH/SSI/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/SSI/$Ssi_Pgt $IMS_PATH/ & sleep 3
			tar -zxvf $IMS_PATH/[ssiSSi]*.tar.gz  -C $IMS_PATH/  & sleep 3
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/ssi/bin/vm.cfg $IMS_PATH/ssi/bin/ & sleep 1
			/bin/cp $CON_BAKPATH/$DATETIME/ssi/bin/svc.conf $IMS_PATH/ssi/bin & sleep 1
			echo ""
			echo "************************************************************************"
			echo "**                                                                    **"
			echo "**              Packages are all updated successfully~                **"
            echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
			echo "**                                                                    **"
			echo "************************************************************************"
			echo ""
			sleep 2
			doChoose
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**         Packetages for update not found,please check.          **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			exit
		fi	
}

#Multistreamer更新
doUpdateMulStr()
{
		#关闭JointStreamer进程
		PID=`ps -ef |grep JointStreamer |grep -v grep | awk '{print $2}'`
		if [ -n "$PID" ]; then
			echo 'begin to kill multiStreamer id:'
			echo $PID
			kill -9 $PID
		else 
			echo "multistreamer is no running..."
		fi

			
		if [ -d $UPLOAD_PATH/multiStreamer ]; then 
			echo ""
            echo "Multistreamer update starting..."
			echo ""
#旧版本文件备份
			echo ""
            echo "Now backup the old packages..."
			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/multiStreamer $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/multiStreamer $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi
			
#新包上传并替换
			echo ""
            echo "Now replace the old packages..."
			echo ""
			rm -rf $IMS_PATH/multiStreamer* & sleep 2
			Mul_Pgt=`ls -lrt $UPLOAD_PATH/multiStreamer/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/multiStreamer/$Mul_Pgt $IMS_PATH/ & sleep 3
			tar -zxvf $IMS_PATH/multiStreamer*.tar.gz  -C $IMS_PATH/  & sleep 3
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/multiStreamer/bin/vm.cfg $IMS_PATH/multiStreamer/bin/ & sleep 1
			/bin/cp $CON_BAKPATH/$DATETIME/multiStreamer/bin/svc.conf $IMS_PATH/multiStreamer/bin & sleep 1
			echo ""
			echo "************************************************************************"
			echo "**                                                                    **"
			echo "**              Packages are all updated successfully~                **"
            echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
			echo "**                                                                    **"
			echo "************************************************************************"
			echo ""
			sleep 2
			doChoose
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**         Packetages for update not found,please check.          **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			exit
		fi	
}

#VCRS更新
doUpdateVCRS()
{
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
			echo ""
            echo "VCRS update starting..."
			echo ""
#旧版本文件备份
			echo ""
            echo "Now backup the old packages..."
			echo ""
			if [ -d "$CON_BAKPATH/$DATETIME" ]; then 			
			    echo "Backup path is already exist,now backup the old files..."
				/bin/cp -r --backup=numbered  $IMS_PATH/VCRS* $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			else 
			    mkdir -p $CON_BAKPATH/$DATETIME
				/bin/cp -r $IMS_PATH/VCRS* $CON_BAKPATH/$DATETIME/ & sleep 4
				echo ""
				echo "********************************************************************"
				echo "**                                                                **"
			    echo "**           Packages are all backuped successfully~              **"
				echo "**                                                                **"
				echo "********************************************************************"
				echo ""
			fi
			
#新包上传并替换
			echo ""
            echo "Now replace the old packages..."
			echo ""
			rm -rf $IMS_PATH/VCRS* & sleep 2
			Vcrs_Pgt=`ls -lrt $UPLOAD_PATH/multiStreamer/ | sed -n '$p' | awk '{print $9}'`
			cp $UPLOAD_PATH/VCRS/$Vcrs_Pgt $IMS_PATH/ & sleep 3
			tar -zxvf $IMS_PATH/VCRS*.tar.gz  -C $IMS_PATH/  & sleep 3
			#替换配置文件
            /bin/cp $CON_BAKPATH/$DATETIME/VCRS*/bin/vm.cfg $IMS_PATH/VCRS*/bin/ & sleep 1
			/bin/cp $CON_BAKPATH/$DATETIME/VCRS*/bin/svc.conf $IMS_PATH/VCRS*/bin & sleep 1
			echo ""
			echo "************************************************************************"
			echo "**                                                                    **"
			echo "**              Packages are all updated successfully~                **"
            echo "** Now please make sure the file %%vm.cfg , svc.conf%% is up_to_date. **"
			echo "**                                                                    **"
			echo "************************************************************************"
			echo ""
			sleep 2
			doChoose
			
		else 
			echo ""
			echo "********************************************************************"
			echo "**                                                                **"
			echo "**         Packetages for update not found,please check.          **"
			echo "**                                                                **"
			echo "********************************************************************"
			echo ""
			exit
		fi	
}

#帮助文档
show_help()
{
		echo ""
		echo "********************************************************************"
		echo "**                                                                **"
		echo "**          Please insert number in {1,2,3,4,5,6,7,8,9}           **"
		echo "**                                                                **"
		echo "********************************************************************"
		echo ""
		doChoose
}

if [ $# -eq 0 ]; then
	doChoose
else
	COMMAND="$1"; shift
fi	 
	
case "$COMMAND" in
 	1)
		doUpdateGUI_UPS
    ;;
    2)
		doUpateMule
    ;;
    3)	
   	    doUpdateSSG
    ;;
    4)	
	    doUpdateSRS
	;;	
	5)
		doUpdateSSI
    ;;
    6)
		doUpdateMulStr
    ;;
    7)	
   	    doUpdateVCRS
    ;;
    8)	
	    exit
	;;
    9)
        show_help
    ;;
    *)
        show_help
	;;
esac

