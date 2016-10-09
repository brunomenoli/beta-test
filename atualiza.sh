#!/bin/sh
BACKUP_DIR=/opt/spfbl/backup
AGORA=`date +%y-%m-%d-%H-%M`
MTA=postfix

mkdir -p "$BACKUP_DIR"

#
# ATENTION
# place the new SPFBL.jar into /root
# and run this script from /root
#
# wget https://github.com/SPFBL/beta-test/raw/master/atualiza.sh
# chmod a+x atualiza.sh
# ./atualiza.sh
#

cd /root
wget https://github.com/SPFBL/beta-test/raw/master/SPFBL.jar

rm /opt/spfbl/SPFBL.new
mv SPFBL.jar /opt/spfbl/SPFBL.new

echo "****    SPFBL  UPDATE    ****"
echo ""

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

cd /opt/spfbl
mv SPFBL.jar "$BACKUP_DIR"/SPFBL.old-"$AGORA"
mv SPFBL.new SPFBL.jar

echo "**** SPFBL - Starting    ****"
java -jar SPFBL.jar &
echo "OK"
sleep 10
cd /root

echo "**** !  Starting MTA   ! ****"
service "$MTA" start
sleep 5

echo "**** SPFBL - Version     ****"
echo ""
echo "VERSION" | nc 127.0.0.1 9875
echo ""
echo "**** !!     FINISH    !! ****"
