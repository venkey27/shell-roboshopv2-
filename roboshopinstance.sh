#! /bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z07587789JER0QOC5489" #REPLACE WITH YOUR ZONE ID
DOMAIN_NAME="exptrack.shop"  #REPLACE WITH YOUR DOMAIN NAME

R='\e[31m'
G='\e[32m'
Y='\e[33m'
N='\e[0m'
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ $# -lt 2 ]; then    # $# gives the number of arguments passed to the script
    echo -e "${R}ERROR:: At least 2 arguments are required${N}"
    echo "USAGE: $0 [create/delete] [instance1] [instance2] ..." # $0 gives the name of the script
    exit 1
fi

ACTION=$1
shift # shift command is used to shift the positional parameters to the left. After this command, $1 will be the second argument, $2 will be the third argument, and so on. This allows us to easily access the instance names in the loop below.           
if [ $ACTION != "create" ] && [ $ACTION != "delete" ]; then  # && is used for logical AND operation. It checks if both conditions are true. this condition checks if the ACTION variable is not equal to "create" and also not equal to "delete". If both conditions are true, it means an invalid action was specified.
    echo -e "${R}ERROR:: first argument must be 'create' or 'delete'. Use 'create' or 'delete'.${N}"
    echo "USAGE: $0 [create/delete] [instance1] [instance2] ..."
    exit 1
fi

get_instance_id(){
    name=$1
    aws ec2 describe-instances --filters "Name=tag:Name,Values=roboshop-$name" "Name=instance-state-name,Values=running" \
        --query "Reservations[0].Instances[0].InstanceId" --output text
}

for instance in $@
do
    INSTANCE_ID=$(get_instance_id $instance)
    if [ $ACTION == "create" ]; then
        if [ $INSTANCE_ID == "None" ]; then
            echo "Launching ec2 instance : roboshop-$instance"
            INSTANCE_ID=$(aws ec2 run-instances \
            --image-id $AMI_ID \
            --instance-type t3.micro \
            --security-groups "roboshop-common" "roboshop-$instance" \
	        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
	        --query 'Instances[0].InstanceId' \
            --output text
            )
            echo "launched instance ID : $INSTANCE_ID"

        else
            echo -e "${Y}INFO:: Instance roboshop-$instance already exists with ID $INSTANCE_ID. Skipping creation.${N}"
        fi

        
        #updating R53 record
        if [ $instance == "frontend" ]; then
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
            echo "Public IP is: $IP"
            R53_RECORD="$DOMAIN_NAME"

        else
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
            echo "Private IP is: $IP"
               R53_RECORD="$instance.$DOMAIN_NAME"
        fi  

        aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch '{
            "Comment": "update A record to new IP",  
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$R53_RECORD'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }'
            echo "updated R53 record for $instance" 
    else
        if [ $INSTANCE_ID == "None" ]; then
            echo "${Y}INFO:: $instance already destroyed , nothing to delete${N}"
        else
            aws ec2 terminate-instances --instance-ids $INSTANCE_ID
            echo "Terminating instance : roboshop-$instance with ID $INSTANCE_ID"
        fi
    fi
 done