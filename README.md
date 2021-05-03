# proxySwitch


## Features
1) Changes proxy in the following locations:
		
	- Settings Menu
	- Environment Variables
	- Apt Configuration
	- [TODO] PacMan
	
2) Only need to save the proxy details once while installing.

3) Can also use a proxy which was not saved during the installation.

4) You can use "No" Proxy as well.

## How To Install
```sh
	git clone https://github.com/LaurentFough/proxySwitch
	cd proxySwitch
	bash install.sh
```

**NOTE : Root priviledges will be required.**

Then enter the number of proxies you want to save and their details.
Save the proxies that you commonly use and have to switch between frequently.

**NOTE : In your ~/.bashrc file, DON'T export any proxy environment variables.**

## How To Use

Use the following command from anywhere in the terminal
> `$ proxyswitch`

It'll display your saved proxies and you can choose from there.

## How To Uninstall
> `$ bash uninstall.sh`

**Please raise an issue if you are not happy with something before uninstalling**

____________________

### About the project author
#### Roopansh Bansal
B.Tech undergraduate (Computer Science & Engineering)  
IIT Guwahati  
India  

roopansh.bansal@gmail.com  
www.linkedin.com/in/roopansh-bansal
