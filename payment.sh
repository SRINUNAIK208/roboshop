#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_Folder="/var/log/shellscript-log"
Script_Name="$(echo $0 | cut -d "." -f1)"
Logs_file="$Logs_Folder/$Script_Name.log"
Script_Dir=$PWD

mkdir -p $Logs_Folder

UserId=$(id -u)

if [ $UserId -eq 0 ]
then 
    echo -e "$G user running the script with root access $N"
else
    echo -e "$R user not running the script with root access $N"
    exit 1
fi

VALIDATE(){
    
    if [ $1 -eq 0 ]
    then
       echo -e " $2 installation... $G success $N"
    else
       echo -e " $2 installation...$R failure $N"
       exit 1
    fi

}


dnf install python3 gcc python3-devel -y
VALIDATE $? "paython3"

id roboshop
if [ $? -eq 0 ]
then
   echo "roboshop system user already created..Nothing to do"
else
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "roboshop user created"
fi


mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "payment artifact"

cd /app 
unzip /tmp/payment.zip
VALIDATE $? "unzip the artifact"

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "package"

cp $Script_Dir/payment.service /etc/systemd/system/payment.service
VALIDATE $? "payment service"

systemctl daemon-reload
systemctl enable payment 
systemctl start payment
VALIDATE $? "start payment service"