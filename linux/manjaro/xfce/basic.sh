printf "\n\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"
echo "Author: Arthur da Silva Egide"
echo "Contact: arthuregide@gmail.com"
echo "Linkedin: linkedin.com/in/arthuregide"
printf "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n\n\n\n"
printf " You need to run with adminstrator permissions. Run 'sudo bash basic.sh'\n\n"

user_home=$1
chmod -R 777 .config/

# Todas as funções utilizadas, para ficar mais limpo o código
source "functions.sh"
source "status.txt"

# Update Pacman
pacman -Syu --noconfirm

# Timeline Restorer
install timeshift

# Git
install git

# Git configure
configure_git

# SSH Key Configure
if [ ${ssh_config} ]; then
    echo "[INFO] SSH-Key Already configured!"
else
  rm -r /home/$user_home/.ssh
  mkdir /home/$user_home/.ssh
  ssh-keygen -t rsa -b 4096 -C $(git config --global user.email) -f /home/$user_home/.ssh/id_rsa
  eval `ssh-agent -s`
  ssh-add /home/$user_home/.ssh/id_rsa
  add_config ssh_config
fi

# Multiplex Terminal
install tmux

# Restore point creation
create_restore_point "born_point" "Initial installation of the operating system"

# Web Navigator Vivaldi
log_base Vivaldi
su -c "pamac build vivaldi --no-confirm >> $log_file_verbose"
log_status web_browser

# Vim terminal text editor
install vim
add_config terminal_text_editor

# Main text editor for Visual Studio Code development
install code

# VSCode Config
yes | cp -r ".config/Code/User/" "/home/${user_home}/.config/Code - OSS"
chmod -R 775 "/home/${user_home}/.config/Code - OSS"
code --install-extension dracula-theme.theme-dracula
code --install-extension Gruntfuggly.todo-tree
code --install-extension aaron-bond.better-comments

# Java JRE and JDK
install jre-openjdk
install jdk-openjdk

# Telegram
install telegram-desktop

# Mouse support [!] Need Reboot [!]
install xf86-input-synaptics input_driver

# Text Editor for notes
install kate
add_config text_editor

# Restore point post install
create_restore_point "basic" "Basic user toolkit installed"

# Clipboard handler
install xclip

# Docker
install docker

# Make
install make

#  GitFlow
git clone https://github.com/petervanderdoes/gitflow-avh.git
cd gitflow-avh
make && make install
cd ..
rm -r gitflow-avh


if [ $input_driver != "1" ]
then
  user_interact "Need to reboot. Want do this now? [y/n]"
  if [ $user_answer = "y" -o $user_answer = "s" ]
  then
    log_base reboot
    log_status reboot
    reboot
  fi
fi

# Removing programs

pacman -Rs $(pacman -Qdtq) --noconfirm

remove text_editor mousepad
remove terminal_text_editor nano
remove web_browser midori

echo "##########################################" >> $log_file
printf "##########################################\n" >> $log_file_verbose
log_finish
