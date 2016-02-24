#!/bin/bash 
#This script is written and tested in CentOS7/RHEL7

#Check required package
for package in "gcc" "curl" "git" 
do
	which_cmd=$(which $package)
	if [[ ! -x $which_cmd ]]; then
		echo "This script requires $package."
		echo "Installing $package........."
		sudo yum -y install $package >/dev/null 2>&1
    	fi
done
#Check if nginx is already installed and running
SERVICE='nginx'
if [ -f /usr/sbin/nginx ]; then
	echo "$SERVICE  ALREADY EXISTED "
	sudo yum -y remove nginx >/dev/null 2>&1
	if [ -d /opt/nginx-script ]; then
		rm -rf /opt/nginx-script 
		echo "Earlier nginx removed and new nginx installation from script begins."
	fi
else
	echo "Nginx Installation Script Starts..." 
fi
info_path=/opt/nginx-script/
install_log=/opt/nginx-script/nginx_log
mkdir $info_path
cd $info_path
touch $install_log

#Install epel-release
sudo yum -y install epel-release >/dev/null 2>&1
echo "Epel-release installed" 

#Install nginx package
sudo yum -y install nginx >/dev/null 2>&1
echo "$SERVICE package installed" 

#Change default port 80 to 8008
sed -i -e 's/80/8008/g' /etc/nginx/nginx.conf
echo "port changed to 8008" >> $install_log 
git_src="https://github.com/puppetlabs/exercise-webpage"
git clone $git_src
echo "cloned content from  $git_src" >> $install_log
yes | cp exercise-webpage/index.html /usr/share/nginx/html/ >> $install_log

#For RHEL7/CentOS7, replace with /etc/init.d/nginx start for other versions
sudo service nginx start>> $install_log

#Test if content is copied to index.html
curl -s -X GET http://localhost:8008 > $info_path/test.index.html
  different=$(diff --brief $info_path/test.index.html $info_path/exercise-webpage/index.html)
  if [ -n "$different" ]; then
    echo "Test GET of index.html failed."
    exit 1
  else
    echo "Test GET of index.html OK"
  fi
echo "Installation completed $SERVICE is running on port 8008" 
#End of script
