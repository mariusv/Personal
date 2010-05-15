#!/bin/sh -
#Primitive IP Camera Capture Script
#Axis 210a Camera
#Use a Cron Job To Control
#Tested under FreeBSD
ROT=$(date "+%b%d%y%H%M")
CAPTOOL=/usr/local/bin/mencoder
CAP_OPT1="-prefer-ipv4 -fps 6 -demuxer lavf"
CAP_OPT2="-nosound -oac mp3lame -ovc xvid -xvidencopts pass=1 -o"
ADDIES="cam1 cam3 cam4 cam5" # IP must be in hosts
STORE=/camera
ISTORE=/str/backup
LOGS=/var/log
DSPACE=200000
USED=`df -hm $STORE | awk '{print $1}'`
CAM_USED=`du -ms $STORE | awk '{print $1}'`
CAM_MAX=200000
STR_USED=`du -ms $ISTORE | awk '{print $1}'`
STR_MAX=200000
unset SUDO_COMMAND
export MKISOFS=/usr/local/bin/mkisofs
BURNSIZE=4196
DEVICE=/dev/cd1
BURNLIST=$(ls $STORE/*.avi)
GROWISOFS=/usr/local/bin/growisofs
MKISOFS=/usr/local/bin/mkisofs
 
#send this in cron email
echo cam_used $CAM_USED
echo str_used $STR_USED
capcam ()
{
        rm ${LOGS}/cam*.log
        for X in ${ADDIES} ;do
        ${CAPTOOL} ${CAP_OPT1} http://${X}/mjpg/video.mjpg ${CAP_OPT2} ${STORE}/${X}.$ROT.avi > ${LOGS}/${X}.log &
done
}
 
cdir  ()
{
        for Y in ${BURNLIST} ;do
        rm $Y
done
}
 
killall -9 mencoder
sleep 3
if [ $STR_USED -lt $STR_MAX ]
          then
        if [ $CAM_USED -lt $BURNSIZE ]
          then
                capcam
          else
        if ${GROWISOFS} -dvd-compat -Z ${DEVICE} -J -R ${BURNLIST}
          then
                cdir
                capcam
          else
        if ${MKISOFS} -o $ISTORE/${ROT}.iso -R ${BURNLIST}
          then
                cdir
                capcam
          else
                echo System Full
        fi
     fi
   fi
fi
