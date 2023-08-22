#!/bin/bash

check_flag () {
	[ ! -f /.flag ] && sudo cp -rf $1 $1.bak || sudo cp -rf $1.bak $1
}

append_file () {
        grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 && clear
}

# Backup
[ -f /etc/default/grub ] && check_flag /etc/default/grub

# Set timer to 20
timeout="$(grep 'GRUB_TIMEOUT=' \/etc\/default\/grub)"
sudo sed -i 's/${timeout}/GRUB_TIMEOUT=20/g' /etc/default/grub
unset timeout

# Remember Last Boot
grub_default="$(grep 'GRUB_DEFAULT=' \/etc\/default\/grub)"
sudo sed -i 's/${grub_default}/GRUB_DEFAULT=saved/g' /etc/default/grub
unset grub_default

# Enable OS Prober
os_prober="$(grep 'GRUB_DISABLE_OS_PROBER=' \/etc\/default\/grub)"

if [ -z ${os_prober} ]; then
	append_file "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub
else
	sudo sed -i 's/${os_prober}/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
fi

unset os_prober

# Enable Submenus
submenu="$(grep 'GRUB_DISABLE_SUBMENU' \/etc\/default\/grub)"
[ ! -z ${submenu} ] && sudo sed -i 's/${submenu}//g' /etc/default/grub
unset submenu

# Enable Splash
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub

# Install Themes
grub_in_theme () {
	cd /tmp/ && rm -rf grub2-themes && git clone https://github.com/vinceliuice/grub2-themes && cd grub2-themes
	[[ ${distro_id} == "arch" ]] && sudo ./install.sh -b -t stylish
	[[ ${distro_id} == "linuxmint" ]] && sudo ./install.sh -b -t vimix
	#[[ ${distro_id} == "endeavouros" ]] && sudo ./install.sh -b -t stylish -i white
}

update_grub () {
	function has_command() {
		command -v $1 &> /dev/null #with "&>", all output will be redirected.
	}

	if has_command update-grub; then
		sudo update-grub
	elif has_command grub-mkconfig; then
		sudo grub-mkconfig -o /boot/grub/grub.cfg
	elif has_command zypper; then
		sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	elif has_command dnf; then
		if [[ -f /boot/efi/EFI/fedora/grub.cfg ]] && (( $(cat /etc/fedora-release | awk '{print $3}') < 34 )); then
		sudo prompt -i "\n Find config file on /boot/efi/EFI/fedora/grub.cfg ...\n"
		sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
	fi
	if [[ -f /boot/grub2/grub.cfg ]]; then
		sudo prompt -i "\n Find config file on /boot/grub2/grub.cfg ...\n"
		sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	fi
  fi
}

case $in_themes in
   y)	grub_in_theme;;
   *)	update_grub;;
esac
