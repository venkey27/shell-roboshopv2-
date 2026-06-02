LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"


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
if [ $USERID -ne 0 ]; then
    echo -e " $TIMESTAMP [ERROR] $R RUN T HE MONGODB SCRIPT WITH ROOT ACCESS $N " | tee -a $LOGS_FILE
    exit 1
fi  

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