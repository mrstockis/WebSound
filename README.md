# WebSound
- Simple music player written in bash
- this program is, as of now, dependent on mpv, youtube-dl, and nano text editor


Features:
- streams any URL, from where youtube-dl can extract a viable media link (vimeo/youtube/soundcloud/internet radio etc.)
- playlist management

Coming:
- config-file
- possibility to use any texteditor
- alternative mediaplayers; vlc, omxplayer
- youtube-dl updater for UNIX-systems


INSTALL
-first install is made by running the install.sh, while in the cloned folder
$
cd .../WebSound/
sudo chmod +x install.sh webSound.sh     #in case e(x)ecute rights are missing
./install.sh
$
> a new folder '.webSound/' will be created in the home-folder '~/', housing all the files
> a new alias 'WebSound' will be asked to be added to '.bashrc', and takes effect after next reboot
> first Run starts automaticly, and the clone-map Can be deleted.

if clone is kept for future updates, re-run the install.sh after new git's been pulled to synchronize
$
cd .../WebSound/
git pull
sudo chmod +x install.sh webSound.sh     #in case e(x)ecute rights are missing
./install.sh
$
