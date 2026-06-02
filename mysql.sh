#! /bin/bash

source ./common.sh
check_root

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Insatalling mysql server"

systemctl enable mysqld &>> $LOGS_FILE
systemctl start mysqld &>> $LOGS_FILE
VALIDATE $? "starting and enabling mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting mysql root password"

print_total_time