#!/bin/bash

# Description: Create New Users or Add Domain Names for Postfix Mail Server

# Variables
M_USER='DB USER HERE'
M_PASS='DB PASS HERE'
M_HOST='DB HOST HERE'
M_DB='DB NAME HERE'
M_CON="mysql -u$M_USER -p$M_PASS -D $M_DB"

echo -e "Hi There... What would you like to do?\n
         Add New Domain [1]\n
         Add New Email for Domain [2]\n
         List All Domains [3]\n
         List All Email IDs [4]\n"
printf "Enter Your Choice: "
read choice

# Functions
function getDomains {
    $M_CON -e 'SELECT name FROM virtual_domains' | sed -e 1d
}

function getUsers {
    $M_CON -e 'SELECT email FROM virtual_users' | sed -e 1d
}

function addDomain {
    DOMAIN="$1"
    $M_CON -e "INSERT INTO virtual_domains  (id ,name) VALUES ('', \"$DOMAIN\")"
}

function addUsers {
    DOMAIN="$1"
    EMAIL="$2"
    PASSWORD="$3"
    DOMAIN_ID=`$M_CON -e "SELECT id FROM virtual_domains WHERE name = \"$DOMAIN\"" |sed -e 1d`
    
    if [ "$DOMAIN_ID" -ge "1" ];then
        $M_CON -e "INSERT INTO virtual_users (id, domain_id, password , email) 
        VALUES ('', '$DOMAIN_ID', ENCRYPT('$PASSWORD', CONCAT('\$6\$', SUBSTRING(SHA(RAND()), -16))), '$EMAIL@$DOMAIN')"
    else
        echo 'Domain Not Valid. Not Present In Database'
    fi
}

echo "===================================="

if [ $choice == 1 ];then
    clear
    printf "Enter the Domain Name: "
    read DOMAIN
    addDomain $DOMAIN
    echo "Domain Added Successfully."
elif [ $choice == 2 ];then
    clear
        printf "Enter the Domain Name: "
        read DOMAIN
        printf "Enter the Email User (without Domain): "
        read EMAIL
        printf "Enter the Password: "
    read PASSWORD
    addUsers $DOMAIN $EMAIL $PASSWORD
    echo "Email Added Successfully."
elif [ $choice == 3 ];then
    clear
    getDomains
elif [ $choice == 4 ];then
    clear
    getUsers
else 
    echo "Wrong Argument..."    
fi
