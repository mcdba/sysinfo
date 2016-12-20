#!/bin/bash 
DB_USER='root';
DB_PASSWD='mysqlpass';
DB_NAME='sysinfo';
# capture tcpdump
DATE=$(date +%Y-%m-%d:%H:%M:%S);
filename=$PWD/tst$DATE.pcap

filename_vnstat=$PWD/$DATE.vnstat
#vnstat -tr 60 > $filename_vnstat & 

#sudo tcpdump  -G 60 -W 1 -w $filename

# write into log return log id
log_id=$(mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -B -N -e "INSERT INTO log () VALUES (); select LAST_INSERT_ID();";);

function write_mysql()
{
	# write section
	mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -B -N -e "INSERT INTO section (log_id,name,data) VALUES ($log_id,'$1','$2');";
}


write_mysql "Load Average  ( Cpu(s)=$(nproc))" "$(php -f la.php $((uptime; nproc)| cat | tr "\n" " "| awk '{gsub(","," ",$0);print $(NF-6)"."$(NF-5)" "$(NF-4)"."$(NF-3)" "$(NF-2)"."$(NF-1)" "$NF}'))";

write_mysql "Network Load (vnstat)" "$(cat $filename_vnstat|awk'NR>1{print $0}')";
rm -f $filename_vnstat

write_mysql "tcpdump Top Talkers src/dst ip, port, pps" "$(sudo tcpdump -nn -r my.pcap tcp or udp and not ip6 | awk '{gsub(/\./," ",$3);gsub(/\./," ",$5);print $3" " $5}' |awk '{print $1"."$2"."$3"."$4"  "$6"."$7"."$8"."$9"  "$5}'|gawk '{a[$1" "$2" "$3]+=1; s+=1} END {PROCINFO["sorted_in"] = "@val_num_desc";for(sip_dip_p in a) printf( "%45s %5d %8.2f \n",sip_dip_p,a[sip_dip_p],a[sip_dip_p]/60) }'| awk '{printf("%17s %17s %8s %5d %8.2f\n",$1,$2,$3, $4, $5)}')";
write_mysql "tcpdump Top Talkers w/o  local ip" "$(sudo tcpdump -nn -r $filename tcp or udp or arp or icmp | awk '{print $3 "\n" $5}' |grep -v -F "$(ip addr | awk '/global/ {print $2}' | cut -d/ -f1)" | cut -sd. -f 1-4 | sort | uniq -c | sort -nr | head -10)";
write_mysql "tcpdump Top Talkers by Packet Size" "$(sudo tcpdump -nn -r $filename| awk '{print int($NF)}'|sort | uniq -c | sort -nr | awk '{ a[++n,1] = $1; a[n,2] = $2; t += $1 } END { for (i = 1; i <= n; i++) printf("%-20s %-15d %d%% \n", a[i,1], a[i,2], 100 * a[i,1] / t)}'| head -10 |awk ' BEGIN{printf("%12s %12s %6s \n","packets","packet size","%")}{printf("%12d %12d %6s \n",$1,$2,$3)}')"
write_mysql "tcpdump by proto,size" "$(sudo tcpdump -nn -r $filename | awk '{print $2 "\t" int($NF)}'|gawk '{a[$1]+=$2; s+=$2} END {PROCINFO["sorted_in"] = "@val_num_desc";for(proto in a) printf( "%15s %15d %d%% \n",proto,a[proto],100*a[proto]/s) }')"
# delete old tcpdump files
rm -f $filename



write_mysql "Disk Usage" "$(df --output=source,pcent,ipcent,target|grep -v -E '% /dev|% /proc|% /sys'|awk '{	p=int(substr($2,1,length($2)-1));	i=int(substr($3,1,length($3)-1)); if(i>p) p=i; if( p>=90) print "<span class=\"crit\">"$0"</span>"; else if(p>=80) print "<span class=\"warn\">"$0"</span>"; else print $0;}')";
write_mysql "Disk Load" "$(iostat -d | awk 'NR > 2 {print $0}')";
write_mysql "Network Load" "$(cat /proc/net/dev |awk ' NR > 2 {print $0}'| awk ' BEGIN {printf("%15s %15s %15s %15s %15s \n","inteface","bytes_recived","packet_recived","bytes_transmit","packet_transmit")} {printf("%15s %15d %15d %15d %15d \n",$1,$2,$3,$10,$11)}')";
write_mysql "dffdded" "$(mpstat | awk 'NR >3{gsub(",",".",$0);printf("%8.1f %%us %8.1f %%sys %8.1f %%idle %8.1f %%iowait \n", $3+$4,$5,$12,$6)}')";
