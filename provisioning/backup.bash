#!/bin/bash
set -eux
# backup and restore cassandra
# author: jagatveer@hotmail.com

today=`date "+%Y%m%d"`
path_to_data="/var/lib/cassandra/data"
path_to_commitlog="/var/lib/cassandra/commitlog"
path_to_backup="/var/lib/cassandra/backup"
log="/var/log/cassandra_backup.log"
backup_server="54.218.73.95"
path_to_remote_backup="/home/ubuntu/cassandra"

check_exit_code() {
        exit_code=$?
        if [ "$exit_code" -ne "0" ] ; then
                echo "$1"
                echo "exit with exitcode $exit_code"
                return 1
        fi

}

backup() {
    nodetool status 1>/dev/null 2>&1
    check_exit_code "cassandra not launch"

    #remove old snapshot
    nodetool clearsnapshot 1>$log 2>&1
    check_exit_code "couldn't delete old backup"
    rm -rf $path_to_backup
    mkdir -p $path_to_backup
    chown cassandra $path_to_backup

    #create backup
    nodetool snapshot -t backup$today 1>$log 2>&1
    check_exit_code "couldn't create backup"

    #collect all backup in one dir
    for dir in `find $path_to_data -name "backup$today"`; do
        mv -f $dir ${path_to_backup}/`echo $dir|sed -e s'\/\%%\g'`
    done

    #save backup
    tar cf ${path_to_backup}.tar ${path_to_backup}
#    rsync --delete -auve 'ssh -i /home/ubuntu/terraform_psnl.pem' $path_to_backup.tar ubuntu@${backup_server}:${path_to_remote_backup}/`hostname -s`${today}.tar 1>$log 2>&1
#    rsync -rq $path_to_backup.tar ${backup_server}::${path_to_remote_backup}/`hostname -s`${today}.tar 1>$log 2>&1
    check_exit_code "couldn't save backup on $backup_server"

    #delete local backup
    rm -rf $path_to_backup
    rm -rf ${path_to_backup}.tar
}

restore() {
    #http://www.datastax.com/docs/1.0/operations/backup_restore
    echo "Are you sure? It'll delete all current data (yes/no)"
    read decision
    decision=`echo $decision|tr [:upper:] [:lower:]|cut -c 1`
    if [ "$decision" != "y" ]; then exit 1; fi
        day=$1
        backups_count=`ls ${path_to_remote_backup}/ |grep $day|wc -l`
        if [ "$backups_count" -eq "0" ]; then
                echo "backup not found, check ${path_to_remote_backup}"
                return 1
        else
                day=`ls ${path_to_remote_backup}/ |grep $day|awk '{print $NF}'`
        fi

    #stop cassandra
    service cassandra stop
    #remove old db files
    rm -rf $path_to_commitlog/*
    find $path_to_data -type f -name "*.db" -delete

    #download the backup and put it in right places
    rm -rf $path_to_backup/restore
    mkdir -p $path_to_backup/
    cp -rf ${path_to_remote_backup}/${day} $path_to_backup/
    tar xf $path_to_backup/${day} -C $path_to_backup/
	for dir in $path_to_backup/var/lib/cassandra/backup/*; do
        dst=`echo $dir|sed -e 's%.*/%%' -e 's/snapshot.*//g' -e 's\%%\/\g'`
        mkdir -p $dst
        mv -f $dir/* $dst/
    done
    chown -R cassandra:cassandra $path_to_data
    service cassandra start
    check_exit_code "coudn't start cassandra"
}

if [ "`id -u`" -ne "0" ]; then
    echo "need root's permissions"
    exit 1
fi

if [ "$1" = "backup" ] ; then
        backup
elif [ "$1" = "restore" ] && [ "$2" != "" ]; then
        restore $2
else
        echo "use $0 {backup|restore day}"
fi
