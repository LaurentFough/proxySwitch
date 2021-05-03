#!/usr/bin/env sh

## Some global variables
DATABASE_DIR="$HOME/.config/proxyswitch"
DATABASE_LOCATION="$HOME/.config/proxyswitch/proxyswitchDB.txt"
PROXIES=()

# Proceed only if root privileges
checkRoot(){
	if [ $EUID -ne 0 ]; then
		echo "[proxySwitch] Do you have proper administration rights? (super-user?)"
		echo "[proxySwitch] Root privileges are required."
		exit
	else
		setupProxies
		return 0
	fi
}

## setup the proxy database location
setupProxies(){
	if [[ ! -d $DATABASE_DIR ]]; then
		sudo mkdir $DATABASE_DIR
		if [[ ! -f $DATABASE_LOCATION ]]; then
			sudo touch $DATABASE_LOCATION
		else
			sudo mv $DATABASE_LOCATION $DATABASE_LOCATION."bkp"
		fi
	fi
	read -p "[proxySwitch] How many proxies do you wanna save ? " numOfProxies
	echo "PROXYCOUNT="$numOfProxies > $DATABASE_LOCATION
	for (( i = 1; i <= $numOfProxies; i++ )); do
		saveProxyDetails $i
	done
	echo "PROXIES=(${PROXIES[@]})" >> $DATABASE_LOCATION
	_finalise
}

## set up the proxy details of each proxy
saveProxyDetails(){
	echo
	echo "[proxySwitch] Enter Details for proxy #$1"
	read -p "[proxySwitch] Enter Proxy (e.g. 202.141.80.24) : " proxy
	read -p "[proxySwitch] Enter Proxy Port (e.g. 3128) : " proxyPort
	read -p "[proxySwitch] Use proxy Authentication? (Y/N) : " -n 1 response
	echo
	case $response in
		y|Y)
			echo "[proxySwitch] Enter you proxy Authentication"
			read -p "[proxySwitch] Enter username : " -r proxyUsername
			read -p "[proxySwitch] Enter Password : " -r proxyPassword
			proxyText=$proxyUsername":"$proxyPassword"@"$proxy":"$proxyPort
			;;
		*)	
			proxyText=$proxy":"$proxyPort
			;;
	esac
	PROXIES+=($proxyText)
}

## install the script and display final message
_finalise(){
	sudo cp proxyswitch.sh /usr/local/bin/proxyswitch
	sudo chmod 755 /usr/local/bin/proxyswitch
	sudo gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '::1', '202.141.*.*', '172.16.*.*']"
	echo
	echo "[proxySwitch] ProxySwitch installed successfully."
	echo "[proxySwitch] Use 'proxyswitch' from terminal to switch proxies."
}

checkRoot
