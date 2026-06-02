#! /bin/bash

app_name=shipping
source ./common.sh
check_root
 

app_setup
java_setup
systemd_setup

dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "installing mysql client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "loading shipping schema to mysql"
else
    echo -e " $TIMESTAMP [INFO]  shipping schema already exists in mysql ... $G skipping schema loading $N " | tee -a $LOGS_FILE        
fi

systemctl daemon-reload &>> $LOGS_FILE
app_restart
print_total_time
