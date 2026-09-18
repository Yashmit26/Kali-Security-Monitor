#!/bin/bash
REPORT="reports/security_report_$(date +%F_+%H-%M).txt"

#colors

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

#Banner

banner()
{
clear

echo "======================================"
echo "========Kali Security Monitor ========"
echo "=====Linux Security Audit Toolkit====="
echo "======================================"
}

#1. System Information

system_info()
{
echo ""
echo "=========SYSTEM INFORMATION==========="

hostnamectl

}

#2. User Information

user_info()
{

echo ""
echo "==========LOGGED-IN USERS============"

who
}

#3. Network Information

network_info()
{
echo ""
echo "==========NETWORK INFORMATION========"

echo ""
echo "[+] Listening Network Ports"

sudo ss -tulnp
}

#4. Disk Usage

disk_monitor()
{

echo ""
echo "============DISK USAGE=============="

df -h
}

#5. Memory Usage

memory_monitor()
{

echo ""
echo "============MEMORY USAGE==========="

free -h
}

#6. Process Monitoring

process_monitor()
{

echo ""
echo " ============TOP PROCESSES=========="

ps aux --sort=-%mem | head -10
}

#7. Security Score

security_score()
{
score=0

echo ""
echo "====================================="
echo "       Security Health Score"
echo "===================================="

#ssh check

if systemctl is-active --quiet ssh
then

echo "[+] SSH Service          : PASS +20"
score=$((score+20))
else
echo "[-] SSH Service          : FAIL  +0"
fi 

# FIREWALL CHECK
if systemctl is-active --quiet ufw
then
echo "[+] Firewall Status     : PASS  +20"
score=$((score+20))
else 
echo "[-] Firewall Status     : FAIL     +0"
fi

#DISK CHECK 

disk=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$disk"  -lt 80 ]
then
echo  "[+] DISK Usage             : PASS     +20"
score=$((score+20))
else
echo "[-] DISK Usage           : HIGH   +0"
fi

#Memory Check

memory=$(free | awk '/Mem:/ {print ($3/$2)*100}')

if (($(echo "$memory < 80"| bc -l) ))
then 

echo "[+] Memory Usage        : PASS +20"
score=$((score+20))
else 
echo "[-] Mmeory Usage      : HIGH    +0"
fi

#Process Check

process=$(ps aux | wc -l)

if [ "$process"  -lt 300 ]
then
echo "[+] Processes            :PASS    +20"
score=$((score+20))

else 
echo "[-] Processes                :HIGH    +0"

fi 

#Final Score
echo ""
echo "------------------------------------------"
echo "Security Score : $score/100"

#Security Level
if [ "$score" -ge 80 ]
then
echo "Security Level : GOOD"

elif [ "$score" -ge 50 ]
then

echo "Security Level : MEDIUM"

else 
echo "Security Level : LOW"
fi

echo "==========-------------=========="
}

#8. Generate Report

generate_report()
{
mkdir -p reports

echo "KALI SECURITY MONITOR REPORT" >> $REPORT
echo "Generated: $(date)" >> $REPORT

echo "" >> $REPORT

echo " ==========SYSTEM INFORMATION==========" >> $REPORT
hostnamectl >> $REPORT

echo "" >> $REPORT

echo "==========USERS========================"
who  >> $REPORT

echo "" >>$REPORT
echo "==========NETWORK=====================">>$REPORT
sudo ss -tulnp >> $REPORT

echo "" >> $REPORT
echo "==================DISK================">> $REPORT
df -h >> $REPORT

echo ""$REPORT

echo "==================MEMORY==============">>$REPORT
free -h  >> $REPORT

echo "" >> $REPORT

echo "===============PROCESS================">>$REPORT
ps aux --sort=%mem | head -10 >> $REPORT


echo ""
echo -e "${GREEN}Report Generated Successfully${NC}"

echo "Saved at: $REPORT"
}

#Main Menu

while true 
do 

banner

echo "
1. System Information
2. Logged-in Users
3. Network Information
4. Disk Usage
5. Memory Usage
6. Process Monitiring
7. Security Sco
re
8. Generated Security Report
9. Exit
"

read -p "Select Option: " choice

case $choice in
1) 
system_info
;;

2)
user_info
;;

3)
network_info
;;

4)
disk_monitor
;;

5)
memory_monitor
;;

6)
process_monitor
;;

7)
security_score
;;

8)
generate_report
;;

9)
echo "Exiting Kali Security Monitor........"
exit
;;

*)
echo "Invalid Option"
;;

esac 

echo ""
read -p "Press Enter to Continue.."
done



