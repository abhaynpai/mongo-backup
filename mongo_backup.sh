#!/bin/bash
source /home/ubuntu/.bashrc;
BASH_ENV=$HOME/.bashrc;

# Steps to use the script
# 1. Edit cron list --> `crontab -e`
# 2. Add this script in the cron as follows
#
# MAILTO=youremail@organization.com
# *pattern* /path/to/script/folder/collections-backup.sh


# If any command fails, then stop the script.
# Someone has to stop the cron manually, debug, fix issue
# and restart the cron.
set -e


###################################################
# Cron Config
###################################################

# Backup folder
BACKUP_FOLDER=/home/ubuntu/backups/

# Max count of backups to keep in the backup folder
BACKUP_COUNT_MAX=10

# List of collections to backup
COLLECTIONS=( collection-1 collection-2 collection-3 collection-4 collection-5 )

# Backup file name. You can choose a format that you like and change the value
BACKUP_FILE=collections.`date +%Y-%m-%d--%H-%M-%S`.tar.gz

# Get the oldest backup
OLDEST_BACKUP=`ls -rt $BACKUP_FOLDER | head -1`

# Get a count of backups available
BACKUP_COUNT=`ls -rt $BACKUP_FOLDER | wc -l`

# MongoDB host IP / Domain
MONGO_HOST=127.0.0.1

# MongoDB Database to backup
MONGO_DB=test


###################################################
# Start Backup
###################################################

# Create tmp folder named cols
echo "Creating TMP Folder for collections"
mkdir cols


# Start exporting collections
for col in "${COLLECTIONS[@]}"
do
	:
	echo -e "\n\n"
	echo "Exporting $col : "
	mongoexport --host $MONGO_HOST --db $MONGO_DB --collection $col --out cols/$col.json
done


# Compress the folder to a backup file
echo -e "\n\n"
echo "Compressing backup collections to $BACKUP_FILE"
tar czvf $BACKUP_FILE cols


# Move backup file
echo -e "\n\n"
echo "Moving Backup file"
mv $BACKUP_FILE $BACKUP_FOLDER


# Remove tmp folder for collections
echo -e "\n\n"
echo "Removing temporary folder for collections"
rm -rf ./cols


# Remove the oldest backup
if [ $BACKUP_COUNT -gt $BACKUP_COUNT_MAX ]; then
	echo -e "\n\n"
	echo "Removing oldest backup : $OLDEST_BACKUP"
	rm $BACKUP_FOLDER/$OLDEST_BACKUP
fi


# List of back up files
echo -e "\n\n"
echo "List of Backups available"
ls -lh $BACKUP_FOLDER