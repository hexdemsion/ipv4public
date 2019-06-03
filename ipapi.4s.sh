#!/usr/bin/env bash
# <bitbar.title>IPv4 Public location</bitbar.title>
# <bitbar.version>v1</bitbar.version>
# <bitbar.author>Malhadi Jr</bitbar.author>
# <bitbar.author.facebook>https://facebook.com/malhadi.jr</bitbar.author.facebook>
# <bitbar.desc>Displays current information about IP public (City, Country (IP)) and daily Islam pray time</bitbar.desc>
# <bitbar.dependencies>Bash GNU JQ CURL afplay</bitbar.dependencies>

export PATH=/usr/local/bin:$PATH
folder_path="/Users/malhadijr/Project/bitbar/file-data"

get_new_ipinfo() {
	resp=`curl "http://ip-api.com/json" -s -L`
	echo "$resp" > $folder_path/ipinfo.json
	ip=`echo $resp | jq -r .query`
	city=`echo $resp | jq -r .city`
	region=`echo $resp | jq -r .regionName`
	country=`echo $resp | jq -r .countryCode`
	country_name=`echo $resp | jq -r .country`
	org=`echo $resp | jq -r .isp`
}

get_last_ipinfo() {
	resp=`cat $folder_path/ipinfo.json`
	ip=`echo $resp | jq -r .query`
	city=`echo $resp | jq -r .city`
	region=`echo $resp | jq -r .regionName`
	country=`echo $resp | jq -r .countryCode`
	country_name=`echo $resp | jq -r .country`
	org=`echo $resp | jq -r .isp`
}

last_ip=`cat $folder_path/ip.txt`
current_ip=`curl -m 7 'https://api.ipify.org?format=json' -s | jq -r .ip`
echo $current_ip > $folder_path/ip.txt

if [[ $current_ip == '' ]]; then
	echo "Offline 😢"
	echo '---'
	echo 'Check your wifi connection | color=red'
	exit
fi

if [[ ! -f $folder_path/ipinfo.json || $last_ip != $current_ip ]]; then
	get_new_ipinfo

	flag_json=`cat $folder_path/flag.json | jq '.[] | select(.code=="'$country'")'`
	flag_emoji=`echo "$flag_json" | jq -r .emoji`

	terminal-notifier -title "IPv4 address obtained: $flag_emoji ($ip)" -message "$city, $region, $country via $org" -open "https://ipapi.co/$ip/json" -sound blow
	echo "[`date`] (NEW) $resp" >> $folder_path/ipinfo.log
else
	get_last_ipinfo
	flag_json=`cat $folder_path/flag.json | jq '.[] | select(.code=="'$country'")'`
	flag_emoji=`echo "$flag_json" | jq -r .emoji`
fi

echo "$city, $country $flag_emoji ($ip)"
echo "---"
echo 'JSON data from http://ip-api.com/json | color=green href=http://ip-api.com/json'
