#!/bin/sh -
#本脚本为系统应用环境搭建脚本,包括JDK,JBOSS,ESB,Tomcat,dic,FTP,ORACLE等的安装，安装前请确保安装文件都准备完毕，安装文件建议放置于/home/ims/update目录下
#LOCAL_IP=` ifconfig | grep "inet addr" | sed -n 1p | awk '{print $2}' | awk -F: '{print $2}' `    #此处默认本地网卡为eth0，若不是，修改截取的行                                         #本机IP(该IP用于JBOSS配置，一般为内网IP)
LOCAL_IP=10.130.128.15
LOCAL_NAME=`uname -a | awk '{print $2}'`
#SRS相关参数
ESB_URL=http://10.130.128.15:9081
#SSI相关参数
WEB_INTER_URL=
HTTP_URL=
SNAPSHOT_LIB_PATH=
SNAPSHOT_SAVE_PATH=
FILE_SEARCH_PATH=
#multiStreamer相关参数
QCS_URL=
ORACLE_IP=                                   #oracle数据库IP
ORACLE_USER=								 #oracle连接用户名
ORACLE_PASSWD=								 #oracle连接密码
IMS_PATH=/usr/local/ims                      #应用存放目录
UPDATE_PATH=/home/ims/update                 #安装文件存放目录
JMS_HOME="$JBOSS_PATH/server/default"        #JMS主目录
HOR_HOME="$JBOSS_PATH/server/hornetq"        #Hornetq主目录
TMP_FILE=tmp_file
SSG_NAME=[ssgSSG]
SRS_NAME=[srsSRS]
SSI_NAME=[ssSS]i
Mul_NAME=multi[sS]treamer
VCRS_NAME=[vcrsVCRS]
doChoose()
{
		echo ""
		echo "********************************************************************"
		echo "**                                                                **"
		echo "**                   1.JDK install                                **"
		echo "**                   2.ESB install                                **"
		echo "**                   3.SSG install                                **"
		echo "**                   4.SRS install                                **"
		echo "**                   5.SSI install                                **"
		echo "**                   6.Multistreamer install                      **"
		echo "**                   7.VCRS install                               **"
		echo "**                   8.Hornetq install                            **"
		echo "**                   9.ESB install                                **"
		echo "**                   e.Exit                                       **"
		echo "**                   h.Help                                       **"
		echo "**                                                                **"
		echo "********************************************************************"
		echo -n "Please choose the subsystem number(like 1): "
read NUM
		
case "$NUM" in
    1)
		doInstallJDK
    ;;
    2)
		doInstallJMS
    ;;
    3)	
   	    doInstallSSG
    ;;
    4)	
	    doInstallSRS
	;;	
	5)
		doInstallSSI
    ;;
    6)
		doInstallMulStr
    ;;
    7)	
   	    doInstallVCRS
    ;;
    8)	
	    doInstallHornetq
	;;
    9)	
	    doInstallESB
	;;
	e)
 		exit
 	;;
    h)
        show_help
    ;;
    *)
        show_help
	;;
esac
}

#configure environment

#JDK install
doInstallJDK()
{
		#check JDK
		if [ -d "$JAVA_HOME" ];then          #这里由于是引用JAVA_HOME变量，需要用双引号
				echo ""
				echo "JDK is already installed!"
				echo ""
			else
				echo ""
 				echo "Now isntalling JDK..."
				echo ""
				mkdir -p /usr/java
				cp $UPDATE_PATH/jdk* /usr/java
				chmod a+x /usr/java/jdk*
				cd /usr/java && ./jdk*
				rm -rf /usr/java/jdk-*
				JAVANAME=`ls -l /usr/java | grep jdk1 | sed -n 1p | awk '{print $9}'`
				JAVA_HOME=/usr/java/$JAVANAME  #JDK主目录
		fi
		
		#/etc/profile
		echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
		echo 'export PATH=$JAVA_HOME/bin:$PATH'  >> /etc/profile
		source /etc/profile

		doChoose
}		
			
#JBOSS install 
doInstallJMS()
{       
	if [ -d "$JBOSS_HOME" ] ; then
			echo ""
			echo "JBOSS is already installed!"
			echo ""
		else 
			echo ""
			echo "now start installing JMS..."
			echo ""
			cp $UPDATE_PATH/jboss*  $IMS_PATH
			tar -zxvf $IMS_PATH/jboss* $IMS_PATH
			#/etc/profile
			JBOSSNAME=`ls -l $IMS_PATH | grep jboss | sed -n 1p | awk '{print $9}'`   
			JBOSS_HOME=$IMS_PATH/$JBOSSNAME                                           #jboss主目录
			echo "export JBOSS_HOME=$JBOSS_HOME" >> /etc/profile
			echo 'export PATH=$PATH:$JBOSS_HOME/bin' >> /etc/profile
			source /ect/profile
		
			#JMS config
			echo "Please check arguments are right:"
			echo "localip:$LOCAL_IP"
			echo "username of orcl:$ORACLE_USER"
			echo "password of orcl:$ORACLE_PASSWD"
			echo -n "Right?(Y/N):"
			read ANSWER
			if [ "x$ANSWER" = "xY" ];then 
					JBOSS_DEPLOY=$JBOSS_HOME/server/default/deploy
		
					#certus.sh
					/bin/cp $JBOSS_HOME/bin/certus.sh $JBOSS_HOME/bin/certus.sh_bak
					cat $JBOSS_HOME/bin/certus.sh_bak | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$LOCAL_IP'/g' > $JBOSS_HOME/bin/certus.sh
		
					#oracle-ds.xml
					/bin/cp $JBOSS_DEPLOY/oracle-ds.xml $JBOSS_DEPLOY/oracle-ds.xml_bak
					#cat $JBOSS_DEPLOY/oracle-ds.xml_bak | sed -e  's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$ORACLE_IP'/g' -e  '32s;\(.*\);\<user-name\>'$ORACLE_USER'\<\/user-name\>;g' -e  '33s;\(.*\);\<password\>'$ORACLE_PASSWD'\<\/password\>;g' > $JBOSS_DEPLOY/oracle-ds.xml
					cat $JBOSS_DEPLOY/oracle-ds.xml_bak | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$ORACLE_IP'/g' |sed '32s;\(.*\);\<user-name\>'$ORACLE_USER'\<\/user-name\>;g' | sed '33s;\(.*\);\<password\>'$ORACLE_PASSWD'\<\/password\>;g'  > $JBOSS_DEPLOY/oracle-ds.xml
        
					#jbossweb.sar/server.xml
					/bin/cp $JBOSS_DEPLOY/jbossweb.sar/server.xml $JBOSS_DEPLOY/jbossweb.sar/server.xml_bak
					cat  $JBOSS_DEPLOY/jbossweb.sar/server.xml_bak | sed '12s/port="\(.\{4\}"\)/port="3000"/g'  > $JBOSS_DEPLOY/jbossweb.sar/server.xml
		
					#jms-remote-qms-ra.rar/META-INF/ra.xml
					/bin/cp $JBOSS_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml  $JBOSS_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml_bak
					cat $JBOSS_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml_bak | sed 's/host=\(.*\);port=\(.\{4\}\)/host='$LOCAL_IP';port=5545/g' >  $JBOSS_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml
		
					#jms-ra.rar/META-INF/ra.xml
					/bin/cp $JBOSS_DEPLOY/jms-ra.rar/META-INF/ra.xml  $JBOSS_DEPLOY/jms-ra.rar/META-INF/ra.xml_bak
					cat $JBOSS_DEPLOY/jms-ra.rar/META-INF/ra.xml_bak | sed 's/host=\(.*\);port=\(.\{4\}\)/host='$LOCAL_IP';port=5545/g' >  $JBOSS_DEPLOY/jms-ra.rar/META-INF/ra.xml
		
					#hornetq/hornetq-configuration.xml
		
				else 
					echo "Please correct these arguments"
					exit 1
		
			fi
	fi

	doChoose
}     
		

#Hornetq配置
doInstallHornetq()
{
		HORNETQ_DEPLOY=$JBOSS_HOME/server/hornetq/deploy
		
		#jbossweb.sar/server.xml
		/bin/cp $HORNETQ_DEPLOY/jbossweb.sar/server.xml $HORNETQ_DEPLOY/jbossweb.sar/server.xml_bak
		cat  $HORNETQ_DEPLOY/jbossweb.sar/server.xml_bak | sed '12s/port="\(.\{4\}"\)/port="3100"/g'  > $HORNETQ_DEPLOY/jbossweb.sar/server.xml
	
		#jms-remote-qms-ra.rar/META-INF/ra.xml
		/bin/cp $HORNETQ_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml  $HORNETQ_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml_bak
		cat $HORNETQ_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml_bak | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$LOCAL_IP'/g' >  $HORNETQ_DEPLOY/jms-remote-qms-ra.rar/META-INF/ra.xml
		
		doChoose
}

#ESB配置
doInstallESB()
{	if [ -d "$MULE_HOME" ] ; then
			echo ""
			echo "ESB is already installed!"
			echo ""
			sleep 3
		else 
			echo ""
			echo "Now start installing ESB..."
			cp $UPDATE_PATH/mule*　$IMS_PATH
			tar -zxvf $IMS_PATH/mule*  $IMS_PATH  

			MULENAME=`ls -l $IMS_PATH | grep mule | sed -n 1p | awk '{print $9}'`
			MULE_HOME=$IMS_PATH/$MULENAME                                         #mule主目录
			#/etc/profile
			echo "export MULE_HOME=$MULE_HOME"   >> /etc/profile
			source /ect/profile
		
			#ESB config
			/bin/cp $MULE_HOME/conf/wrapper.conf  $MULE_HOME/conf/wrapper.conf.bak
			cat $MULE_HOME/conf/wrapper.conf.bak | sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'$LOCAL_IP'/g' > $MULE_HOME/conf/wrapper.conf
	fi

	doChoose
}	


doInstallSSG()
{
	exit
}

doInstallSRS()
{   
	#判断IMS_PATH是否存在
	if [ -d "$IMS_PATH" ]; then
		echo "the home of terminal program is $IMS_PATH "
	else
			mkdir -p $IMS_PATH
	fi

	 sleep 3  
	#upload package
	cp $UPDATE_PATH/SRS/SRS*.tar.gz $IMS_PATH
	tar -zxvf $IMS_PATH/SRS*.tar.gz -C $IMS_PATH > /dev/null
	rm -rf $IMS_PATH/SRS*.tar.gz 
	cd $IMS_PATH/srs && sh install_srs.sh
	#echo $PWD
    #vm.cfg 
    cat $IMS_PATH/srs/bin/vm.cfg > $TMP_FILE
    sed -e '2s/.*/VMS_NAME=SRS_'$LOCAL_NAME'/' -e '3s/.*/VMS_IP_ADDR='$LOCAL_IP'/' -e '28s#.*#ESB_URL='$ESB_URL'#' $TMP_FILE >  $IMS_PATH/srs/bin/vm.cfg
    #svc.conf
    rm -rf $TMP_FILE

    doChoose
}

doInstallSSI()
{
	#判断IMS_PATH是否存在
	if [ -d "$IMS_PATH" ]; then
		echo "the home of terminal program is $IMS_PATH "
	else
			mkdir -p $IMS_PATH
	fi

    sleep 3  
 	#upload package
	cp $UPDATE_PATH/SSI/[ssiSSi]*.tar.gz $IMS_PATH
	tar -zxvf $IMS_PATH/[ssiSSi]*.tar.gz -C $IMS_PATH > /dev/null
	rm -rf $IMS_PATH/[ssiSSi]*.tar.gz 
	cd $IMS_PATH/ssi && sh install_ssi.sh
	#echo $PWD
    #vm.cfg 
    cat $IMS_PATH/ssi/bin/vm.cfg > $TMP_FILE
    sed -e '2s/.*/VMS_NAME=SSI_'$LOCAL_NAME'/' -e '3s/.*/VMS_IP_ADDR='$LOCAL_IP'/' -e '10s#.*#WEB_INTER_URL='$WEB_INTER_URL'#' -e '14s#.*#HTTP_URL='$HTTP_URL'#' -e '19s#.*#SNAPSHOT_LIB_PATH='$SNAPSHOT_LIB_PATH'#' -e '22s#.*#SNAPSHOT_SAVE_PATH='$SNAPSHOT_SAVE_PATH'#' -e '25s#.*#FILE_SEARCH_PATH='$FILE_SEARCH_PATH'#' $TMP_FILE >  $IMS_PATH/ssi/bin/vm.cfg
    #svc.conf
    rm -rf $TMP_FILE

    doChoose
}

doInstallMulStr()
{
	#判断IMS_PATH是否存在
	if [ -d "$IMS_PATH" ]; then
		echo "the home of terminal program is $IMS_PATH "
	else
			mkdir -p $IMS_PATH
	fi
	 sleep 3  
	#upload package
	cp $UPDATE_PATH/multiStreamer/multiStreamer*.tar.gz $IMS_PATH
	tar -zxvf $IMS_PATH/multiStreamer*.tar.gz -C $IMS_PATH > /dev/null
	rm -rf $IMS_PATH/multiStreamer*.tar.gz 
#	cd $IMS_PATH/$Mul_NAME && sh install_ssi.sh

	#echo $PWD
    #vm.cfg 
    cat $IMS_PATH/multiStreamer/bin/vm.cfg > $TMP_FILE
    sed -e '2s/.*/VMS_NAME=_'$LOCAL_NAME'/' -e '3s/.*/VMS_IP_ADDR='$LOCAL_IP'/' -e '10s#.*#QCS_URL='$QCS_URL'#'  $TMP_FILE >  $IMS_PATH/multiStreamer/bin/vm.cfg
    #svc.conf
    rm -rf $TMP_FILE

    doChoose
}

doInstallVCRS()
{
	#判断IMS_PATH是否存在
	if [ -d "$IMS_PATH" ]; then
		echo "the home of terminal program is $IMS_PATH "
	else
			mkdir -p $IMS_PATH
	fi
	 sleep 3  
	#upload package
	cp $UPDATE_PATH/VCRS/VCRS*.tar.gz $IMS_PATH
	tar -zxvf $IMS_PATH/VCRS*.tar.gz -C $IMS_PATH > /dev/null
	rm -rf $IMS_PATH/VCRS*.tar.gz 
#	cd $IMS_PATH/vcrs && sh install_ssi.sh

	#echo $PWD
    #vm.cfg 
    cat $IMS_PATH/VCRS*/bin/vm.cfg > $TMP_FILE
    sed -e '2s/.*/VMS_NAME=_'$LOCAL_NAME'/' -e '3s/.*/VMS_IP_ADDR='$LOCAL_IP'/' -e '10s#.*#QCS_URL='$QCS_URL'#'  $TMP_FILE >  $IMS_PATH/VCRS*/bin/vm.cfg
    #svc.conf
    rm -rf $TMP_FILE

    doChoose
}

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
	
case "$NUM" in
    1)
		doInstallJDK
    ;;
    2)
		doInstallJMS
    ;;
    3)	
   	    doInstallSSG
    ;;
    4)	
	    doInstallSRS
	;;	
	5)
		doInstallSSI
    ;;
    6)
		doInstallMulStr
    ;;
    7)	
   	    doInstallVCRS
    ;;
    8)	
	    doInstallHornetq
	;;
    9)	
	    doInstallESB
	;;
	e)
 		exit
 	;;
    h)
        show_help
    ;;
    *)
        show_help
	;;
esac
