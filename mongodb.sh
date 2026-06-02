#! /bin/bash
source ./comman.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding mongo repo file"                       #$? -> this is the exit code of the last command

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "installing mongodb"

systemctl enable --now mongod
VALIDATE $? "starting and enabling mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections to mongodb"

systemctl restart mongod
VALIDATE $? "restarting mongodb"
