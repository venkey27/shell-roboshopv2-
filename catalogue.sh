#! /bin/bash

app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service # this is the service file which we have created in our local and we are copying it to the systemd directory to avoid any issues with the path of the service file
VALIDATE $? "copying catalogue systemd service file"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding mongo repo file"

dnf install mongodb-mongosh -y &>> $LOGS_FILE
VALIDATE $? "installing mongodb client"

INDEX=$(mongosh --host mongodb.exptrack.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.exptrack.shop </app/db/master-data.js &>> $LOGS_FILE
    VALIDATE $? "load products data to catalogue database"
else        
    echo -e " $TIMESTAMP [INFO]  catalogue database already exists ... $G skipping database initialization$N " | tee -a $LOGS_FILE
fi

systemctl enable catalogue &>> $LOGS_FILE
systemctl restart catalogue &>> $LOGS_FILE
VALIDATE $? "restarting and enabling catalogue service"

print_total_time
