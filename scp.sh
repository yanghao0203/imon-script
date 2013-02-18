#!/bin/sh -
#本脚本用于复制安装文件到相关服务器
#执行本脚本时请确认本机与各服务器可无密码SSH登录
doScpJBOSS()
{
    exit
}

doScpGUI_UPS()
{
    
}

doScpSSG()
{   
	for SSG_LIST in $(cat $PWD/ssg_server_list)
    do
    #找最新的子系统压缩包并拷贝到远程主机
    Ssg_Pgt=`ls -lrt | sed -n '$p' | awk '{print $9}'`
    ssh root@$SSG_LIST "[-d /home/ims/update/SSG ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SSG_LIST "mkdir -p /home/ims/update/SSG"
    else 
        echo ""
    fi

	scp -r /home/ims/update/SSG/$SSG_Pgt root@$SSG_LIST:/home/ims/update/SSG/
    #把安装脚本和更新脚本拷贝到远程主机
    scp  -r /home/ims/update/SCRIPT root@$SSG_LIST:/home/ims/update/
    done

}

doScpSRS()
{   
	for SRS_LIST in $(cat $PWD/srs_server_list)
    do
    Srs_Pgt=`ls -lrt /home/ims/update/SRS/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$SRS_LIST "[-d /home/ims/update/SRS ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SRS_LIST "mkdir -p /home/ims/update/SRS"
    else 
        echo ""
    fi

	scp -r /home/ims/update/SRS/$Srs_Pgt root@$SRS_LIST:/home/ims/update/SRS/
    scp  -r /home/ims/update/SCRIPT root@$SRS_LIST:/home/ims/update/
    done

}

doScpSSI()
{
	for SSI_LIST in $(cat $PWD/ssi_server_list)
    do
    Ssi_Pgt=`ls -lrt /home/ims/update/SSI/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$SSI_LIST "[-d /home/ims/update/SSI ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$SSI_LIST "mkdir -p /home/ims/update/SSI"
    else 
        echo ""
    fi
    
	scp -r /home/ims/update/SSI/$Ssi_Pgt root@$SSI_LIST:/home/ims/update/SSI/
    scp  -r /home/ims/update/SCRIPT root@$SSI_LIST:/home/ims/update/
    done
}

doScpMulStr()
{   
    for MulStr_LIST in $(cat $PWD/multistreamer_server_list)
    do
    Mul_Pgt=`ls -lrt /home/ims/update/multiStreamer/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$MulStr_LIST "[-d /home/ims/update/multiStreamer ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$MulStr_LIST "mkdir -p /home/ims/update/multiStreamer"
    else 
        echo ""
    fi

	scp -r /home/ims/update/multiStreamer/$Mul_Pgt root@$MulStr_LIST:/home/ims/update/multiStreamer/
    scp  -r /home/ims/update/SCRIPT root@$MulStr_LIST:/home/ims/update/
    ssh $MulStr_LIST -l root "chmod a+x /home/ims/update/"

    done

}

doScpVCRS()
{
	for VCRS_LIST in $(cat $PWD/vcrs_server_list)
    do
    VCRS_Pgt=`ls -lrt /home/ims/update/VCRS/ | sed -n '$p' | awk '{print $9}'`
    ssh root@$VCRS_LIST "[-d /home/ims/update/multiStreamer ]" 
    STAT=$?
    if [ $STAT = 1 ]; then
        ssh root@$VCRS_LIST "mkdir -p /home/ims/update/multiStreamer"
    else 
        echo ""
    fi
    ssh $VCRS_LIST -l root "mkdir -p /home/ims/update/VCRS"
	scp -r /home/ims/update/VCRS/$VCRS_Pgt root@$VCRS_LIST:/home/ims/update/VCRS/
    scp -r /home/ims/update/SCRIPT root@$VCRS_LIST:/home/ims/update/
    done

}

