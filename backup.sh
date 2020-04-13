#!/bin/bash

##
## Creates a backup of the folder $1 to $HOME/Backups using delta updates
##

folder_to_copy=$1

# If path inserted doesnt start with "/", it means the user used a relative path, so we replace it with 
# an absolute path, starting at root
if [ $(echo ${1} | cut -c 1) != "/" ]
then
	folder_to_copy=${1//\.\/*/}
	folder_to_copy="$(pwd)/${folder_to_copy}"
fi


# Checking if dir specified by user exists
if [ ! -d "${folder_to_copy}" ]
then
	echo "This directory doesn't exist! Please, go back and enter a valid directory"
	exit
fi


# Checking if there is a index file
if [ ! -f "$HOME/Backups/index.db" ]
then
	touch "$HOME/Backups/index.db"
	index_value="0"
else
	index_value=$(grep "${folder_to_copy}" "$HOME/Backups/index.db")
fi


# The name for the compressed backup file will be generated based on the number of 
# files already present in index.db
if [ "${index_value}" = "" ]
then
	echo "Nao existe procurado"
	index_value=$(tail -n1 $HOME/Backups/index.db | cut -d " " -f 1)
else
	index_value=$(echo "${index_value}" | cut -d " " -f 1)
fi
index_value=$(expr "${index_value}" + 1)


# Assingning name to file and creating an entry for it on the index file
name_file="N${index_value}"
echo "${index_value} ${folder_to_copy}" >> "$HOME/Backups/index.db"



#################################################
##                                             ##
##        Starting Backup tool script          ##
##                                             ##
#################################################




echo -e "\nStarting backup tool for ${folder_to_copy}...\n\n"
sleep 3


# If a backup folder doesn't exist, create it
if [ ! -d "${HOME}/Backups" ]
then
	echo -e "A backup folder didn't exist, so I created it\n"
	mkdir "${HOME}/Backups"
	sleep 2
fi
cd $HOME/Backups


# Creating temporary folder, to not make a mess on the $HOME/Backups folder
mkdir tmp
temp_folder="$HOME/Backups/tmp/"


# Checking if a previous backup of this folder already exists
if [ ! -f "./backup-${name_file}.tar.gz" ]
then
	echo -e "Previous backup not found. Creating one now...\n\n"
	sleep 3

else
	echo -e "Found a previous backup for this folder! Extracting it now...\n\n"
	echo ""
	sleep 3
	tar -xv --use-compress-program=pigz -f "./backup-${name_file}.tar.gz" -C "${temp_folder}"
fi


echo -e "Creating backup now. This program requires root permissions. Please, type the password in case it asks...\n\n"
sleep 3


# In case user decides to make a copy of the / folder, exclude these
sudo rsync -PaXv "${folder_to_copy}" --exclude={"/dev","/proc","/sys","/run","/tmp","/mnt","/media","/home","/lost+found"} "${temp_folder}/files"

echo ""
echo ""


cd "${temp_folder}"
echo "Backup finished! Compressing backup folder so it uses as little space as possible"
echo "This is a backup of ${folder_to_copy}, generated on $(date)" > ./README.dat
sleep 3
sudo tar -cv --use-compress-program=pigz -f "./backup-${name_file}.tar.gz" ./*

sudo chown $USER ./*
sudo chmod 664 ./*

mv "./backup-${name_file}.tar.gz" "$HOME/Backups/"


sudo rm -rf "${temp_folder}"
cd $HOME


echo "Finished! Thanks for using!"
sleep 3
