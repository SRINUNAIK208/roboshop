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
dnf module enable nodejs:20 -y
VALIDATE $? "nodejs disabled and enabled"

dnf install nodejs -y
VALIDATE $? "nodejs"


id roboshop
if [ $? -eq 0 ]
then
  echo "roboshop system user already created...nothing to do"
else
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  VALIDATE $? "roboshop user created"
fi


mkdir -p /app

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "cart artificart"

cd /app 
unzip /tmp/cart.zip
VALIDATE $? "unzip the artifact"

cd /app 
npm install 
VALIDATE $? "nodejs packages"

cp $Script_Dir/cart.service /etc/systemd/system/cart.service

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
VALIDATE $? "enable and start cart"



