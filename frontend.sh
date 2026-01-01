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

dnf module list nginx
VALIDATE $? "displayed module list of nginx"

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
VALIDATE $? "Disabled and enabled nginx"

dnf install nginx -y
VALIDATE $? "nginx"

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "enabled and started nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removed defsult content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloaded roboshop artifact"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzip artifact"

cp $Script_Dir/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "setup roboshop application"

systemctl restart nginx 
VALIDATE $? "restared nginx server"