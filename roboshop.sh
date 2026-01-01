#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
Security_ID="sg-00028162e61c10305"
Instance=("frontend" "catalogue" "payment" "shipping" "user" "mongodb" "sql" "rabbitmq" "redis" "cart" "dispatch")
Zone_ID="Z0311053ECKFL0X0CB0M"
Domain_Name="srinunayak.online"

for instance in "$@"
do
 Instance_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-00028162e61c10305 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
      IP=$(aws ec2 describe-instances --instance-ids $Instance_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
      IP=$(aws ec2 describe-instances --instance-ids $Instance_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP Address::$IP"


    aws route53 change-resource-record-sets \
  --hosted-zone-id $Zone_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$instance'.'$Domain_Name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '
done
