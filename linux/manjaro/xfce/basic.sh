printf "\n\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"
echo "Author: Arthur da Silva Egide"
echo "Contact: arthuregide@gmail.com"
echo "Linkedin: linkedin.com/in/arthuregide"
printf "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n\n\n\n"
printf " You need to run with adminstrator permissions. Run 'sudo bash basic.sh'\n\n"

log_file_verbose="log_basic_verbose.txt"
log_file="log_basic.txt"
config_file="user.conf"
user_home=$1
success=0
fails=0
source $config_file
chmod -R 777 .config/

install() {
  log_base ${1}
  pacman -Sy ${1} --noconfirm --verbose >> $log_file_verbose
  log_status ${2}
}

remove(){
  if [ ${!1} = "1" ]; then
    log_base ${1}
    sudo pacman -Rsu ${2} --noconfirm >> $log_file_verbose
    log_status ${2} "remove"
  fi
}

log_base () {
  echo "##########################################" >> $log_file
  printf "## ${1} " >> $log_file

  echo "##########################################" >> $log_file_verbose
  printf "## ${1} " >> $log_file_verbose
}

log_status(){
  if [ $? -eq 0 ]; then
    printf "[SUCCESS]\n" >> $log_file
    success=$((success+1))
    if [ ${1} ]; then 
      add_config $1 
    fi
  else
    if [ ${2} ]; then 
      printf "[OK]\n" >> $log_file
      success=$((success+1))
      if [ ${1} ]; then 
        add_config $1 "remove"
      fi
    else
      printf "[FAIL]\n" >> $log_file
      fails=$((fails+1))
    fi
  fi
}

log_finish(){
  echo "[SUCESS] $success" >> $log_file
  echo "[FAIL] $fails" >> $log_file
  printf "##########################################\n\n" >> $log_file
}

add_config(){
  if [ ${!1} ]; then
    echo "[INFO] ${1} Already configured!"
  else
    if [ ${2} ]; then 
      echo "${1}=0" >> $config_file
    else
      echo "${1}=1" >> $config_file
    fi
  fi
}

create_restore_point(){
  add_config ${1}
  if [ ${!1} ]; then
    echo "[INFO] ${1} already exist, check 'sudo timeshift --list'"
  else
    timeshift --create --snapshot ${1} --comments ${2} --verbose >> $log_file_verbose    
  fi
}

user_interact(){
  echo "=-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-="
  echo ">>>>> ${1}"
  echo "=-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-="
  printf ":"
  read user_answer
}

configure_git(){
  
  if [ ${git_config} ]; then
    echo "[INFO] Git Already configured!"
  else
    user_interact "Git user.name. Enter your name: "
    git config --global user.name "${user_answer}"

    user_interact "Git user.email. Enter your email: "
    git config --global user.email "${user_answer}"

    echo ":::::::::::::::::::::::::::::::::"
    echo ":::::::::::::::::::::::::::::::::"
    echo ":::::::::::::::::::::::::::::::::"
    echo ""
    echo "Your informations"
    echo ""
    echo "git.name : $(git config --global user.name)"
    echo "git.email: $(git config --global user.email)"
    echo ":::::::::::::::::::::::::::::::::"
    echo ":::::::::::::::::::::::::::::::::"
    echo ":::::::::::::::::::::::::::::::::"
    user_interact "Confirm ?[y/n]"
    if [ ${user_answer:0:1} = "y" -o ${user_answer:0:1} = "s" ]; then
      git config --global core.editor vim
      add_config git_config
    else 
      configure_git
    fi
  fi
}

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
