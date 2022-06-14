#!/bin/sh

TARGET=dropbox

# Backup erstellen
opcode system_backup -ds nosync

# Sicherung in den Cloud-Speicher hochladen
mv /var/conf/backupdata/Backup_* Backup
rclone copy Backup "${TARGET}":"$(cat /etc/hostname)"

if [ $? == 0 ] ; then
  logger -t ${TARGET}  -p local0.info \
    "Sicherung der Konfiguration nach ${TARGET} erfolgreich"
  exit 0
else
  logger -t ${TARGET} -p local0.error \
    "Sicherung der Konfiguration nach ${TARGET} fehlgeschlagen"
  exit 1
fi
