#!/bin/bash
BACKUP_DIR=/tmp/backups
 
if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters" >&2
    exit 1
fi
 
if [ ! -d "$1" ]; then
    echo "Source directory not exists" >&2
    exit 2 
fi

re='^[0-9]+$'
if ! [[ $2 =~ $re ]] ; then
   echo "Backup number is not a number" >&2; exit 3
fi
 
#make BACKUP_DIR if not exist
[ -d $BACKUP_DIR ] || mkdir $BACKUP_DIR

#transform source name using sed and tr
BACKUP_FILENAME=${1//\//-}
DATE=$(date '+%Y-%m-%d-%H-%M-%S')
BACKUP_FILENAME=${BACKUP_FILENAME// /"\ "}
BACKUP_FILENAME=${BACKUP_FILENAME/-/}
echo $BACKUP_FILENAME
#tar czf "$BACKUP_DIR"/"$BACKUP_FILENAME"-"$DATE".tar.gz "$1" 
tar czf "$BACKUP_DIR"/"$BACKUP_FILENAME"-"$DATE".tar.gz "$1" 2> /dev/null || { echo "Tar error" >&2 ; exit 5; }
BACKUPS_COUNT=$(ls "$BACKUP_DIR"/"$BACKUP_FILENAME"-*.tar.gz | wc -l)
echo $BACKUPS_COUNT
echo $(($BACKUPS_COUNT-$2))
#archive it and save to dir
#delete the oldest backup if limit overflow
if (($BACKUPS_COUNT-$2 > 0)); then
{ ls -t "$BACKUP_DIR"/"$BACKUP_FILENAME"-*.tar.gz |tail -n $(($BACKUPS_COUNT-$2))  | xargs -d '\n' -r rm; } || { echo "Old backups delete error" >&2 ; exit 6; }
else
echo "Don't need to delete old backups"
fi

