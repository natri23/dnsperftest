#!/usr/bin/env bash

command -v bc > /dev/null || { echo "bc was not found. Please install bc."; exit 1; }
{ command -v drill > /dev/null && dig=drill; } || { command -v dig > /dev/null && dig=dig; } || { echo "dig was not found. Please install dnsutils."; exit 1; }

echo "Use 'sort -k 22 -n' to sort results"

NAMESERVERS=`cat /etc/resolv.conf | grep ^nameserver | cut -d " " -f 2 | sed 's/\(.*\)/&#&/'`

PROVIDERS="
1.1.1.1#cloudflare 
1.0.0.1#cloudflare2 
4.2.2.1#level3 
8.8.8.8#google
8.8.4.4#google 
9.9.9.9#quad9 
80.80.80.80#freenom 
208.67.222.123#opendns 
199.85.126.20#norton 
185.228.168.168#cleanbrowsing 
176.103.130.131#adguardold2
176.103.130.130#adguardold2
156.154.70.3#neustar 
8.26.56.26#comodo
203.162.4.191#VNPT
203.162.4.190#VNPT2
203.113.131.1#Viettel1
203.113.188.1#Viettel0
203.113.131.2#Viettel2
203.113.131.3#Viettel3
210.245.24.20#FPT
210.245.24.22#FPT2
94.140.14.14#adguard
94.140.15.15#adguard2
"

# Domains to test. Duplicated domains are ok
DOMAINS2TEST="www.google.com drive.google.com facebook.com www.youtube.com www.reddit.com  wikipedia.org twitter.com gmail.com www.google.com photos.google.com"


totaldomains=0
printf "%-18s" ""
for d in $DOMAINS2TEST; do
    totaldomains=$((totaldomains + 1))
    printf "%-8s" "test$totaldomains"
done
printf "%-8s" "Average"
echo ""


for p in $NAMESERVERS $PROVIDERS; do
    pip=${p%%#*}
    pname=${p##*#}
    ftime=0

    printf "%-18s" "$pname"
    for d in $DOMAINS2TEST; do
        ttime=`$dig +tries=1 +time=2 +stats @$pip $d |grep "Query time:" | cut -d : -f 2- | cut -d " " -f 2`
        if [ -z "$ttime" ]; then
	        #let's have time out be 1s = 1000ms
	        ttime=1000
        elif [ "x$ttime" = "x0" ]; then
	        ttime=1
	    fi

        printf "%-8s" "$ttime ms"
        ftime=$((ftime + ttime))
    done
    avg=`bc -lq <<< "scale=2; $ftime/$totaldomains"`

    echo "  $avg"
done


exit 0;
