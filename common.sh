LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

USERID=$(id -u)
R='\e[31m'
G='\e[32m'
Y='\e[33m'
N='\e[0m'
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo -e " $TIMESTAMP [INFO] Starting $0 script execution... $N " | tee -a $LOGS_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $TIMESTAMP [ERROR] $R RUN the SCRIPT WITH ROOT ACCESS $N " | tee -a $LOGS_FILE
        exit 1
    fi  
} 

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e " $TIMESTAMP [ERROR] $2 ... $R failure $N " | tee -a $LOGS_FILE
        exit 1
    else
        echo -e " $TIMESTAMP [INFO]  $2 ... $G is successfully completed $N " | tee -a $LOGS_FILE
    fi
}

print_total_time(){
    echo -e " $TIMESTAMP [INFO] Total time taken: $G$SECONDS seconds$N" | tee -a $LOGS_FILE
}

app_setup(){
    id roboshop &>> $LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
        VALIDATE $? "creating roboshop user"
    else
        echo -e " $TIMESTAMP [INFO]  roboshop user already exists ... $G skipping user creation $N " | tee -a $LOGS_FILE        
    fi

    rm -rf /app &>> $LOGS_FILE
    VALIDATE $? "removing existing application code"

    rm -rf /tmp/$app_name.zip &>> $LOGS_FILE
    VALIDATE $? "removing existing $app_name zip"

    mkdir -p /app &>> $LOGS_FILE
    VALIDATE $? "creating application directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOGS_FILE
    cd /app 
    unzip /tmp/$app_name.zip &>> $LOGS_FILE
    VALIDATE $? "downloading and extracting $app_name code"
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOGS_FILE
    dnf module enable nodejs:20 -y &>> $LOGS_FILE
    dnf install nodejs -y &>> $LOGS_FILE
    VALIDATE $? "installing nodejs"
    npm install &>> $LOGS_FILE
    VALIDATE $? "installing nodejs dependencies"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service # this is the service file which we have created in our local and we are copying it to the systemd directory to avoid any issues with the path of the service file
    VALIDATE $? "copying $app_name systemd service file"
 
    systemctl deamon-reload &>> $LOGS_FILE
    systemctl enable $app_name &>> $LOGS_FILE
    VALIDATE $? "enabling $app_name service"
}

app_restart(){
    systemctl restart $app_name &>> $LOGS_FILE
    VALIDATE $? "restarting $app_name service"
}