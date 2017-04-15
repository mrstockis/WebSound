## WebSound
- Simple terminal music player, written in bash
* this program is - as of now - dependent on `mpv`, `youtube-dl`, and the `nano` text editor

#### Features:
- streams any URL, from where youtube-dl can extract a viable media link (youtube/soundcloud/internet radio etc.)
- playlist management

#### INSTALL
First `cd to/the/cloned_folder/` then run the `install.sh`
```
bash install.sh
```  
A new folder `.webSound/` will be created in the home-folder `~/` housing all the files; `~/.webSound/all_files`  
A new alias `WebSound` will be asked to be added to `~/.bashrc` which takes effect after next reboot.  
First Run starts automatically, and the clone-map Can be deleted.  

If clone is kept for future updates, re-run the `../clone_folder/install.sh` after new git's been pulled to synchronize.  
Go to clone `cd to/the/cloned_folder/`  
then
```
git pull  
bash install.sh
```
