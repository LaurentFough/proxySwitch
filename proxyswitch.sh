#!/usr/bin/env sh

## Source the Proxy Database
source "$HOME/.config/proxyswitch/proxyDB.txt"

## Proceed only if root privileges
_checkRoot(){
	if [ $EUID -ne 0 ]; then
		echo "[proxySwitch] Do you have proper administration rights? (super-user?)"
		echo "[proxySwitch] Root privileges are required."
		exit
	else
		proxyChoice
		return 0
	fi
}

## ask user which proxy they want to use
proxyChoice(){
	clear
	echo "[proxySwitch] You have $PROXYCOUNT saved proxies."
	echo

	echo "[proxySwitch] 0 > USE NO PROXY"
	echo

	for (( i = 1; i <= $PROXYCOUNT; i++ )); do
		proxy="${PROXIES[$i-1]}"
	
		## display choice number
		echo -n "[proxySwitch] $i > "
	
		## display proxy:port and username
		sed 's/\(.*\):.*@\(.*\)/\2  \1/' <<< "$proxy"
		echo
	done

	echo "[proxySwitch] $i > SOME OTHER PROXY"
	echo

	read -p "[proxySwitch] Chose any one option : " proxyChoice
	
	## check if in range
	if [[ $proxyChoice -gt '0' && $proxyChoice -le $PROXYCOUNT ]]; then
		# proxyChoice=$((proxyChoice-1))
		## Read the proxy details from the database
		proxy="${PROXIES[$proxyChoice-1]}"
		## Set that proxy
		setProxy $proxy
	elif [[ $proxyChoice == $(($PROXYCOUNT + 1)) ]]; then
		## Set a new Proxy
		newProxy
	elif [[ $proxyChoice == '0' ]]; then
		## No Proxy
		proxyNone 'none'
	else
		echo "[proxySwitch] Invalid Proxy Selected."
		echo "[proxySwitch] proxySwitch Failed."
	fi
}

## Calls functions to set proxy in different fields
setProxy(){
	## Remove all the previous Proxy Settings
	proxyNone

	## System Settings Proxy 
	proxySYS $1
	## Apt Proxy Configuration
	proxyAPT $1
	## Environment variables set up
	proxyENV $1
	## exporting in .bashrc file
	proxyBASHRC $1

	source $HOME/.bashrc
	
	echo "[proxySwitch] New proxy settings applied."
	echo "[proxySwitch] proxySwitch Successful."
}

## set the System proxy
proxySYS(){
	proxy="$1"
	proxy=$(sed 's/.*@\(.*\)/\1/' <<< "$proxy")
	proxyPROXY=$(sed 's/\(.*\):.*/\1/' <<< "$proxy")
	proxyPORT=$(sed 's/.*:\(.*\)/\1/' <<< "$proxy")

	sudo gsettings set org.gnome.system.proxy mode 'manual';
	sudo gsettings set org.gnome.system.proxy.http host $proxyPROXY && sudo gsettings set org.gnome.system.proxy.http port $proxyPORT;
	sudo gsettings set org.gnome.system.proxy.https host $proxyPROXY && sudo gsettings set org.gnome.system.proxy.https port $proxyPORT
	sudo gsettings set org.gnome.system.proxy.ftp host $proxyPROXY && sudo gsettings set org.gnome.system.proxy.ftp port $proxyPORT
	sudo gsettings set org.gnome.system.proxy.socks host $proxyPROXY && sudo gsettings set org.gnome.system.proxy.socks port $proxyPORT
	sudo gsettings set org.gnome.system.proxy.all host $proxyPROXY && sudo gsettings set org.gnome.system.proxy.all port $proxyPORT
}

## set the apt proxy
proxyAPT(){
	proxy="$1"
	
	sudo echo -e "Acquire::http::proxy \"http://$proxy/\";\nAcquire::https::proxy \"https://$proxy/\";\nAcquire::ftp::proxy \"ftp://$proxy/\";\nAcquire::socks::proxy \"socks://$proxy/\";\nAcquire::all::proxy \"https://$proxy/\";" >> /etc/apt/apt.conf
}

## set up the environment variables in the proxy
proxyENV(){
	proxy="$1"
	
	sudo echo -e "http_proxy=\"http://$proxy/\"\nhttps_proxy=\"https://$proxy/\"\nftp_proxy=\"ftp://$proxy/\"\nsocks_proxy=\"socks://$proxy/\"\nall_proxy=\"https://$proxy/\"" >> /etc/environment

	export http_proxy="http://$proxy/"
	export https_proxy="https://$proxy/"
	export socks_proxy="socks://$proxy/"
	export ftp_proxy="ftp://$proxy/"
	export all_proxy="https://$proxy/"
}

## exporting the variables in the bashrc file.
proxyBASHRC(){
	proxy="$1"

	sudo echo -e "## Proxy settings by proxyswitch\nexport http_proxy=\"http://$proxy/\"\nexport https_proxy=\"https://$proxy/\"\nexport socks_proxy=\"socks://$proxy/\"\nexport ftp_proxy=\"ftp://$proxy/\"\nexport all_proxy=\"https://$proxy/\"" >> $HOME/.bashrc
}

## Set no proxy ... Remove all the previous proxy settings 
proxyNone(){
	## System Settings Proxy
	if [[ $1 == 'none' ]]; then
		sudo gsettings set org.gnome.system.proxy mode 'none'
	fi

	## Apt Proxy Configuration
	sudo sed -i.bak '/http::proxy/d' /etc/apt/apt.conf
	sudo sed -i.bak '/https::proxy/d' /etc/apt/apt.conf
	sudo sed -i.bak '/socks::proxy/d' /etc/apt/apt.conf
	sudo sed -i.bak '/ftp::proxy/d' /etc/apt/apt.conf
	sudo sed -i.bak '/all::proxy/d' /etc/apt/apt.conf
	

	## Environment variables set up
	sudo sed -i.bak '/http_proxy/d' /etc/environment
	sudo sed -i.bak '/https_proxy/d' /etc/environment
	sudo sed -i.bak '/ftp_proxy/d' /etc/environment
	sudo sed -i.bak '/socks_proxy/d' /etc/environment
	sudo sed -i.bak '/all_proxy/d' /etc/environment

	## exporting in .bashrc file
	sudo sed -i.bak '/proxySwitch/d' $HOME/.bashrc
	sudo sed -i.bak '/http_proxy/d' $HOME/.bashrc
	sudo sed -i.bak '/https_proxy/d' $HOME/.bashrc
	sudo sed -i.bak '/ftp_proxy/d' $HOME/.bashrc
	sudo sed -i.bak '/socks_proxy/d' $HOME/.bashrc
	sudo sed -i.bak '/all_proxy/d' $HOME/.bashrc

	echo "[proxySwitch] All previous proxy settings removed."
}

## Set a new proxy not saved in the database 
newProxy(){
	echo
	echo "[proxySwitch] Enter Details for proxy : "
	read -p "[proxySwitch] Proxy (e.g. 202.141.80.24) : " proxy
	read -p "[proxySwitch] Proxy Port (e.g. 3128) : " proxyPort
	read -p "[proxySwitch] Use proxy Authentication? (Y/N) : " -n 1 response
	echo
	case $response in
		y|Y)
			echo "[proxySwitch] Enter you proxy Authentication"
			read -p "[proxySwitch] Enter Username : " -r proxyUsername
			read -p "[proxySwitch] Enter Password : " -r proxyPassword
			proxy=$proxyUsername":"$proxyPassword"@"$proxy":"$proxyPort
			;;
		*)	
			proxy=$proxy":"$proxyPort
			;;
	esac

	setProxy $Proxy
}

_checkRoot
