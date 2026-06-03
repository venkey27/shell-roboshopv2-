#! /bin/bash

app_name=frontend
source ./common.sh
check_root


dnf module disable nginx -y &>> $LOGS_FILE
dnf module enable nginx:1.24 -y &>> $LOGS_FILE
dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "installing nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default nginx content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "extracting frontend code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "removing existing nginx configuration file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying new nginx configuration file"
 
systemctl restart nginx &>> $LOGS_FILE
app_restart
print_total_time
