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
dnf module disable nodejs -y
VALIDATE $? "Disabled nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabled nodejs"

dnf install nodejs -y
VALIDATE $? "Installed nodejs"

id roboshop
if [ $? -eq 0 ]
then
   echo "roboshop user already created...Nothing to do"
else
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Created roboshop system user"
fi

mkdir -p /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "download roboshop artifact"

cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "unzip artifact"

npm install 
VALIDATE $? "installed package"

cp $Script_Dir/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy catalogue service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "started calalogue"

cp $Script_Dir/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y
VALIDATE $? "mongodb client created"

mongosh --host mongodb.srinunayak.online </app/db/master-data.js
VALIDATE $? "data is loading"

