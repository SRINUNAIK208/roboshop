
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


dnf module disable redis -y
dnf module enable redis:7 -y
VALIDATE $? "Enables redis"

dnf install redis -y 
VALIDATE $? "redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "remote ports are changed"

sed  -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
VALIDATE $? "protection mode changed"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "enable and start"