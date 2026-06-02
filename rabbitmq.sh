#! /bin/bash
source ./common.sh
check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "adding rabbitmq repo file"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? "starting and enabling rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGS_FILE
VALIDATE $? "creating rabbitmq username and password"

print_total_time