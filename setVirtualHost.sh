#!/bin/bash

#Filename:      createVhost.sh
#Created:       30/08/2012
#Author:        MJC
#Modified:      -
#
#       2012


#Setup global variables..
SITES_AVAILABLE="/etc/apache2/sites-available/"         #Default for ubuntu 12.04
SITES_ENABLED="/etc/apache2/sites-enabled/"              #Default for ubuntu 12.04
DEFAULT_LOC="/var/www/"                                 #Default for ubuntu 12.04


#Output the user the option to choose to setup a whole new virtual host or just a subdomain
echo "Is this a subdomain? (Y/N): "
read TYPE

#If the option is setup a new virtual host, do this..
if [ "$TYPE" = "N" ] || [ "$TYPE" = "n" ]; then

	#If it is not a subdomain, include the domain urk
	echo "Enter the base url, eg (michaelchidley.co.uk): "
	read BASE_URL
        
        
        #Check whether the website directory exists
        if [ ! -d "$DEFAULT_LOC$BASE_URL" ]; then 
                echo "THE SPECIFIED DIRECTORY LOCATION ($DEFAULT_LOC$BASE_URL) DOES NOT EXIST!! ABORTING"
                exit
        fi
        
        
        SYS_LOC=$DEFAULT_LOC$BASE_URL
        
        echo ""
        echo "Enter the domain admin email address, eg (chiders@gmail.com): "
        read ADM_EML


#Append the data string to a variable.. easiest way
NEW_DOMAIN=$(cat <<EOF
<Virtualhost *:80>

      # domain: $BASE_URL
      # public: http://www.$BASE_URL
      
      # Admin email, Server Name (domain name) and any aliases
      ServerAdmin $ADM_EML
      ServerName  $BASE_URL
      ServerAlias www.$BASE_URL
      DocumentRoot $SYS_LOC

</Virtualhost>
EOF
)

        #Output the contents including the variables with values to the vhost file
        echo "$NEW_DOMAIN" > $SITES_AVAILABLE$BASE_URL
        echo ""
        echo ""

        #Change directory to the sites-enabled and setup a symbolic link to the newly created file
        cd $SITES_ENABLED; ln -s $SITES_AVAILABLE$BASE_URL .
        
        #Output a message to show the user the operation has been a success
        echo "Virtual Host: $BASE_URL Successfully Setup!"
        echo ""


#Else, if they want to setup a subdomain do this..
else
        
        #Ask the user for the domain name, only the base domain is needed here
        echo "Enter the the name of the root domain, eg (michaelchidley.co.uk): "
        read BASE_URL
        
        
        #Again, if the directory does not exist, output an error
        if [ ! -d "$DEFAULT_LOC$BASE_URL" ]; then 
                echo "THE SPECIFIED DIRECTORY LOCATION ($DEFAULT_LOC$BASE_URL) DOES NOT EXIST!! ABORTING"
                exit
        fi
                
        
        #Ask the user to input the name of the desired subdomain
        echo ""
        echo "Enter the name of the sub domain, eg (dev): "
        read SUB_DOM
        
        #Assume the location of the file (tested on Ubuntu 12.04)
        echo ""
        echo "Assuming $DEFAULT_LOC$BASE_URL is the location..."

        #Ask for a email address to be associated with the subdomain
        echo ""
        echo "Enter the domain admin email address, eg (chiders@gmail.com): "
        read ADM_EML

        
#Append the data string to a variable.. easiest way
SUB_DOMAIN=$(cat <<EOF


<VirtualHost *:80>
        ServerAdmin $ADM_EML
        ServerName $SUB_DOM.$BASE_URL
        DocumentRoot $DEFAULT_LOC$BASE_URL/$SUB_DOM
</VirtualHost>
EOF
)

        #Store the contents of SUB_DOMAIN into the already existing file, appending it to the end user the >> operator instead of >
        echo "$SUB_DOMAIN" >> $SITES_AVAILABLE$BASE_URL
        echo ""
        echo ""
        
        #Output a successful message to the user
        echo "Subdomain: $SUB_DOM Has Been Successfully Setup!"
        echo ""

       
fi 