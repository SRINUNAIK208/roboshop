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






cp $Script_Dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "rabbitmq repo setup"

dnf install rabbitmq-server -y
VALIDATE $? "rabbitmq"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "start rabbitmq"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "username and password setup for rabbitmq"