#!/bin/sh
export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
 
BACKUP_DIR=/opt/spfbl/backup
AGORA=`date +%y-%m-%d-%H-%M`
MTA=postfix
 
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p $BACKUP_DIR
fi
 
#
# ATENTION
# place the new SPFBL.jar into /tmp
# and run this script from /root
#
# wget https://github.com/SPFBL/beta-test/raw/master/atualiza.sh
# chmod a+x atualiza.sh
# ./atualiza.sh
#
 
wget https://github.com/SPFBL/beta-test/raw/master/SPFBL.jar -O /tmp/SPFBL.jar
if [ ! -f "/tmp/SPFBL.jar" ]; then
    echo "Can't download https://github.com/SPFBL/beta-test/raw/master/SPFBL.jar"
fi
 
echo "****    SPFBL  UPDATE    ****"
echo
 
echo "****   Current Version   ****"
echo "VERSION" | nc 127.0.0.1 9875
 
echo "**** !!  Stoping MTA  !! ****"
service "$MTA" stop
 
echo "**** SPFBL - Store cache ****"
echo "STORE" | nc 127.0.0.1 9875
 
echo "**** SPFBL - Backup      ****"
echo "DUMP" | nc 127.0.0.1 9875 > "$BACKUP_DIR"/spfbl-dump-"$AGORA".txt
 
echo "**** SPFBL - Shutdown    ****"
echo "SHUTDOWN" | nc 127.0.0.1 9875
 
 
mv /opt/spfbl/SPFBL.jar $BACKUP_DIR/SPFBL.jar-"$AGORA"
mv /tmp/SPFBL.jar /opt/spfbl/SPFBL.jar
 
echo "**** SPFBL - Starting    ****"
java -jar /opt/spfbl/SPFBL.jar &
 
if [ "$(ps auxwf | grep java | grep SPFBL | grep -v grep | wc -l)" -eq "1" ]; then
    echo "OK"
    sleep 10
else
    exit -1
fi
 
echo "**** !  Starting MTA   ! ****"
service "$MTA" start
sleep 5
 
echo "**** SPFBL - New Version ****"
echo ""
echo "VERSION" | nc 127.0.0.1 9875
echo ""
echo "**** !!     FINISH    !! ****"
