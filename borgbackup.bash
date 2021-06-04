#!/bin/bash
# borgbackup.bash - borgbackup script by Praveen Nelson v.1.4

systemctl start mnt.mount

BORG_DIRECTORY="/mnt/borgbackup/domain.com/borg-backup-repo"

if [ -d "$BORG_DIRECTORY" ]
then
    echo "Directory $BORG_DIRECTORY exists."
    borg create -s --progress $BORG_DIRECTORY::'{hostname}-{now:%Y-%m-%d}' /srv
    rsync -avh /srv/mysqlbackups/ /mnt/borgbackup/domain.com/mysqlbackups/ --delete
else
    echo "Error: Directory $BORG_DIRECTORY does not exists."
    echo "therefore backup cannot be run"
fi

if [[ $? == 0 ]]; then
        MSG="domain.com NextCloud Files Backup success"
        ICON={now:%Y-%m-%d}
else
        MSG="Backup failed... See root's dead.letter for details."
        ICON=dialog-warning
fi

#sudo -u $USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USERID/bus notify-send 'BorgBackup' "$MSG" --icon=$ICON
systemctl stop mnt.mount

SUBJECT="domain.com BorgBackup notification"

/usr/sbin/ssmtp -t << EOF
To: email@domain.com
Subject: $SUBJECT

$MSG
$ICON

Cheers,
Me
EOF
