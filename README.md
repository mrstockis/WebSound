## WebSound
- Simple terminal music player, written in bash
* this is a hobby-project to learn about linux and the bash language
* the program is - as of now - dependent on `mpv`\*, `youtube-dl`, `w3m` and the `nano`\* text editor  
	\*can be changed

#### Features:
- streams audio from URL containing media (youtube/internet-radio etc.)
- playlist management create/add/edit
- youtube search/play/add
- small config-section within webSound.sh to more easily adjust some parameters

#### INSTALL
First `cd to/the/cloned_folder/` then run the `install.sh`
```
bash install.sh
```  
A new folder `.webSound/` will be created in the home-folder `~/` housing all the files; `~/.webSound/all_files`  
A new alias `WebSound` will be asked to be added to `~/.bashrc` which takes effect after next reboot.  
First Run starts automatically, and the clone-map Can be deleted.  

#### Update
If clone is kept for future updates, re-run the `../clone_folder/install.sh` after new git's been pulled to synchronize.  
Go to clone `cd to/the/cloned_folder/`  
then
```
git pull  
bash install.sh
```
