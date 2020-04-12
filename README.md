# Backup tool

This script makes delta updates (https://en.wikipedia.org/wiki/Delta_update) of a given directory and saves a tarball version to $HOME/Backups. It is possible to make a backup of any folder you want to. 

Making backups of very large folders (like /home) is not suggested, since they take a lot of space, even when compressed. After the backup is completed, the script will compress the files into a tarball (.tar.gz extension) and save it to $HOME/Backups to save as much space as possible.


## Depends on

* rsync
* pigz
			

## Usage 

./backup.sh $1, where $1 is the path to a folder.


## WARNING 

As of now, $1 can be an absolute path (starting at /) or a relative path. You just CANNOT use ../path/to/dir or ../../path/to/dir.
You can use ./path/to/dir or just path/to/dir


