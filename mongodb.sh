#!/bin/bash



R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_Folder="/var/log/shellscript-log"
Script_Name="$(echo $0 | cut -d "." -f1)"
Logs_file="$Logs_Folder/$Script_Name.log"

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

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "mongodb repo setup done"

dnf install mongodb-org -y 
VALIDATE $? "mongodn installation is done"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "enabled and started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing conf file for remote connection"

systemctl restart mongod
VALIDATE $? "restarted mongodb"


