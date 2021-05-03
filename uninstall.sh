#!/usr/bin/env sh

## Proceed only if root privileges
checkRoot(){
	if [ $EUID -ne 0 ]; then
		echo "[proxySwitch] Do you have proper administration rights? (super-user?)"
		echo "[proxySwitch] Root privileges are required."
		exit
	else
		uninstall
		return 0
	fi
}

## Uninstall
uninstall(){
	sudo rm -r $HOME/.config/proxyswitch
	sudo rm /usr/local/bin/proxyswitch

	echo "[proxySwitch] Uninstall successfull."
}

checkRoot
