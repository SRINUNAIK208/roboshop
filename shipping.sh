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
dnf install maven -y

id roboshop
if [ $? -eq 0 ]
then
   echo "roboshop system user already created..Nothing to do"
else
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "roboshop user created"
fi

rm -rf /app
mkdir -p /app 

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "shipping artifact"

cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "unzip atrifact"

mvn clean package 
VALIDATE $? "maven package"
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "jat files copied"

cp $Script_Dir/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "created shiiping service"

systemctl daemon-reload
systemctl enable shipping 
systemctl start shipping
VALIDATE $? "start shiiping service"

dnf install mysql -y 
VALIDATE $? "sql client"

mysql -h sql.srinunayak.online -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "loading schema"

mysql -h sql.srinunayak.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "loading user data"

mysql -h sql.srinunayak.online -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "loading Master data"

systemctl restart shipping
VALIDATE $? "restart shipping service"











