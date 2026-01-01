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

dnf install mysql-server -y
VALIDATE $? "mysql"

systemctl enable mysqld
systemctl start mysqld  
VALIDATE $? "enable and start"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "set password"