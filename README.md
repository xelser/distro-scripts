# My Distro Setups
These setups are accompanied by the scripts and for personal use ***ideally***.
### Clone the repo
```
git clone https://github.com/xelser/distro-scripts
./distro-scripts/install.sh
```
---
## :: Fedora (GNOME) ::
> Some configurations for some apps
#### Zoom: Enable Wayland screen share
```
sed -i 's/enableWaylandShare=false/enableWaylandShare=true/g' $HOME/.var/app/us.zoom.Zoom/config/zoomus.conf
```
##### Recommendations
> Just in case you need to setup these again.
- [rEFInd](https://www.rodsbooks.com/refind/getting.html) | [Theme](https://github.com/bobafetthotmail/refind-theme-regular)
> Already Included in the script. Download the `.rpm` again if needs to be updated.
- [Bibata Cursor](https://github.com/ful1e5/Bibata_Cursor/releases) | Theme : `Modern-Classic`
