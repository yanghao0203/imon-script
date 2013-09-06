#!/bin/sh -
#================================================================
#title=scp.sh
#written by yanghao
#本脚本用于复制安装文件到相关服务器
#可用于上传安装文件至单独服务器，也可以上传全部，详见：show_help
#执行本脚本时请确认本机与各服务器可无密码SSH登录
#================================================================

#Environment Variables
FILE_HOME=/home/ims/          #新版本存放路径，新版本文件夹命名类似：iMON.01.05.05
IMON_VERSION=iMON.01.05.05    #此处为版本号，即为新版文件夹名，需要更改为最新版本号

#判断scp后跟随的参数（参数为主机名），参数为空时执行doCheck
doChoose()
{
if [ $# = 0 ]; then
    doCheck
    else
        echo -n "Servers waiting to update are "
        echo $*
        echo -n "Please check the name of these Servers is right[yes|no]:"
        read answer 
        if [ $answer = xyes ] ; do 
            while [ $# != 0 ]; do
                case $1 in
                    ups*)
                        doScpGUI_UPS
                        ;;
                    re*)
                        doScpReceive
                        ;;
                    sc*)    
                        doScpScheduler
                        ;;
                    ac*)    
                        doScpAC
                        ;;  
                    vd*)
                        doScpeVD
                        ;;
                    vl*)
                        doScpVL
                        ;;
                    ep*)    
                        doScpEpgtracer
                        ;;
                    ke*)    
                        doScpKettle
                        ;;
                    es*)
                        doScpESB
                        ;;
                    ssg*)
                        doScpSSG
                        ;;
                    ssi*)
                        doScpSSI
                        ;;
                    srs*)
                        doScpSRS
                        ;;
                    vcrs*)
                        doScpVCRS
                        ;;
                    multistreamer*)
                        doScpMulStr
                        ;;
                esac
                shift
            done
            else 
            exit
        fi
fi
}

doCheck()
{
 for HOSTNAME in $(cat /etc/hosts | sed -n '15,60p' | awk '{print $1}')
    do
        case "$HOSTNAME" in
            ups*)
                doScpGUI_UPS
                ;;
            re*)
                doScpReceive
                ;;
            sc*)    
                doScpScheduler
                ;;
            ac*)    
                doScpAC
                ;;  
            vd*)
                doScpeVD
                ;;
            vl*)
                doScpVL
                ;;
            ep*)    
                doScpEpgtracer
                ;;
            ke*)    
                doScpKettle
                ;;
            es*)
                doScpESB
                ;;
            ssg*)
                doScpSSG
                ;;
            ssi*)
                doScpSSI
                ;;
            srs*)
                doScpSRS
                ;;
            vcrs*)
                doScpVCRS
                ;;
            multistreamer*)
                doScpMulStr
                ;;
            *)
                show_help
                ;;
        esac
    done
}

doScpJBOSS()
{
    exit
}

doScpGUI_UPS()
{
    for GUI_UPS_LIST in ups
    do 
    echo $GUI_UPS_LIST
    #复制最新的系统包到远程主机
    ssh root@$GUI_UPS_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$GUI_UPS_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$GUI_UPS_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新

    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon.war root@$GUI_UPS_LIST:/home/ims/update/JAVA
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/Qms.war root@$GUI_UPS_LIST:/home/ims/update/JAVA
    scp  -r $FILE_HOME$IMON_VERSION/multi-build/imon-ups-impl* root@$GUI_UPS_LIST:/home/ims/update/JAVA
    done
}

doScpReceive()
{
    for RECEIVER_LIST in receiver1 receiver2 receiver3 receiver4 receiver5 receiver6
    do 
    echo $RECEIVER_LIST
    #复制最新的系统包到远程主机
    ssh root@$RECEIVER_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$RECEIVER_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$RECEIVER_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新

    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/receiver.war root@$RECEIVER_LIST:/home/ims/update/JAVA
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-receiver-cluster* root@$RECEIVER_LIST:/home/ims/update/JAVA
    
    done
}

doScpScheduler()
{
    for SCHEDULER_LIST in scheduler1 scheduler2
    do 
    echo $SCHEDULER_LIST
    #复制最新的系统包到远程主机
    ssh root@$SCHEDULER_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SCHEDULER_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$SCHEDULER_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新
    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/Scheduler.war root@$SCHEDULER_LIST:/home/ims/update/JAVA
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-scheduler-cluster* root@$SCHEDULER_LIST:/home/ims/update/JAVA
    
    done
}

doScpESB()
{
    for ESB_LIST in esb1 esb2
    do 
    echo $ESB_LIST
    #复制最新的系统包到远程主机
    ssh root@$ESB_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$ESB_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$ESB_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新
    fi
    scp  -r $FILE_HOME$IMON_VERSION/MULE-ESB/* root@$ESB_LIST:/home/ims/update/JAVA
    done
}

#approvalchecker
doScpAC()
{
    for AC_LIST in ac1 ac2
    do 
    echo $AC_LIST
    #复制最新的系统包到远程主机
    ssh root@$AC_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$AC_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$AC_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新
    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-approvalchecker-cluster* root@$AC_LIST:/home/ims/update/JAVA
    done
}

#violationdetector
doScpVD()
{
    for VD_LIST in vd1 vd2
    do 
    #复制最新的系统包到远程主机
    ssh root@$VD_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$VD_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$VD_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新

    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-violationdetector-cluster* root@$VD_LIST:/home/ims/update/JAVA
    done
}

#violationlocator
doScpVL()
{
    for VL_LIST in vl1 vl2
    do 
    #复制最新的系统包到远程主机
    ssh root@$VL_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$VL_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$VL_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新

    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-violationlocator-impl* root@$VL_LIST:/home/ims/update/JAVA
    done
}

#epgtracer
doScpEpgtracer()
{
    for EPGTRACER_LIST in epgtracer1 epgtracer2
    do 
    #复制最新的系统包到远程主机
    ssh root@$EPGTRACER_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$EPGTRACER_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$EPGTRACER_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新

    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-epgtracer-cluster* root@$EPGTRACER_LIST:/home/ims/update/JAVA
    done
}

#kettle
doScpKettle()
{
    for KETTLE_LIST in kettle1 kettle2
    do 
    #复制最新的系统包到远程主机
    ssh root@$KETTLE_LIST "[ -d /home/ims/update/JAVA ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$KETTLE_LIST "mkdir -p /home/ims/update/JAVA"
    else 
        ssh root@$KETTLE_LIST "rm -rf /home/ims/update/JAVA/*"     #删除原有系统包文件，确保update目录中系统包为最新
    fi
    scp  -r $FILE_HOME$IMON_VERSION/multi-cluster/imon-kettle-cluster* root@$KETTLE_LIST:/home/ims/update/JAVA
    done
}

doScpSSG()
{   
#	for SSG_LIST in $(cat $PWD/server_list/ssg_list)
    for SSG_LIST in ssg1 ssg2 ssg3 ssg4 ssg5 ssg6 ssg7 ssg8 ssg9 ssg10
    do
    #找最新的子系统压缩包并复制到远程主机
    ssh root@$SSG_LIST "[ -d /home/ims/update/SSG ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SSG_LIST "mkdir -p /home/ims/update/SSG"
    else 
        ssh root@$SSG_LIST "rm -rf /home/ims/update/SSG/*"
    fi

	scp -r $FILE_HOME$IMON_VERSION/SSG*/* root@$SSG_LIST:/home/ims/update/SSG/
#    scp  -r /home/ims/update/imon-script root@$SSG_LIST:/home/ims/update/
    done
}

doScpSRS()
{   
#	for SRS_LIST in $(cat $PWD/server_list/srs_list)
    for SRS_LIST in srs1 srs2 srs3 srs4
    do
    ssh root@$SRS_LIST "[ -d /home/ims/update/SRS ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SRS_LIST "mkdir -p /home/ims/update/SRS"
    else 
        ssh root@$SRS_LIST "rm -rf /home/ims/update/SRS/*"
    fi

	scp -r$FILE_HOME$IMON_VERSION/SRS*/* root@$SRS_LIST:/home/ims/update/SRS/
#    scp  -r /home/ims/update/imon-script root@$SRS_LIST:/home/ims/update/
    done

}

doScpSSI()
{
#	for SSI_LIST in $(cat $PWD/server_list/ssi_list) 
    for SSI_LIST in ssi1 ssi2 ssi3 ssi4 ssi5 ssi6 
    do
#    Ssi_Pgt=`ls -lrt /home/ims/update/SSI/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$SSI_LIST "[ -d /home/ims/update/SSI ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SSI_LIST "mkdir -p /home/ims/update/SSI"
    else 
         ssh root@$SSI_LIST "rm -rf /home/ims/update/SSI/*"
    fi
    
	scp -r $FILE_HOME$IMON_VERSION/SSi*/* root@$SSI_LIST:/home/ims/update/SSI/
#    scp  -r /home/ims/update/imon-script root@$SSI_LIST:/home/ims/update/
    
#   ssh $SSI_LIST -l root "chmod a+x /home/ims/update/"
#   echo "$SSI_LIST copy done"

    done
}

doScpMulStr()
{   
    #for MulStr_LIST in $(cat $PWD/server_list/multistreamer_list)
    for MulStr_LIST in imon_cntv imon_bestv imon_sd imon_sz imon_sc imon_hb imon_hn
    do
#    Mul_Pgt=`ls -lrt /home/ims/update/multiStreamer/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$MulStr_LIST "[ -d /home/ims/update/multistreamer ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$MulStr_LIST "mkdir -p /home/ims/update/multistreamer"
    else 
        ssh root@$MulStr_LIST "rm -rf /home/ims/update/multistreamer/*"
    fi

	scp -r $FILE_HOME$IMON_VERSION/multistreamer*/* root@$MulStr_LIST:/home/ims/update/multistreamer/
#    scp  -r /home/ims/update/imon-script root@$MulStr_LIST:/home/ims/update/
    
#    ssh $MulStr_LIST -l root "chmod a+x /home/ims/update/"
#    echo "$MulStr_LIST copy done"
    done

}

doScpVCRS()
{
	#for VCRS_LIST in $(cat $PWD/server_list/vcrs_list)
    for  VCRS_LIST in vcrs1 vcrs2 vcrs3 vcrs4 vcrs5 vcrs6
    do
#    VCRS_Pgt=`ls -lrt /home/ims/update/VCRS/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$VCRS_LIST "[ -d /home/ims/update/VCRS ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$VCRS_LIST "mkdir -p /home/ims/update/VCRS"
#        echo "create success"
    else 
       ssh root@$VCRS_LIST "rm -rf /home/ims/update/VCRS/*"
    fi
	scp -r $FILE_HOME$IMON_VERSION/update/VCRS*/* root@$VCRS_LIST:/home/ims/update/VCRS/
#    scp -r /home/ims/update/SCRIPT root@$VCRS_LIST:/home/ims/update/
#    ssh $VCRS_LIST -l root "chmod a+x /home/ims/update/"
#    echo "$VCRS_LIST copy done"
    done
}

#帮助文档
show_help()
{
   echo "help!!!!"
}

doChoose