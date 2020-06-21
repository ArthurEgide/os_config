printf "\n\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"
echo "Author: Arthur da Silva Egide"
echo "Contact: arthuregide@gmail.com"
echo "Linkedin: linkedin.com/in/arthuregide"
printf "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n\n\n\n"
printf " You need to run with adminstrator permissions. Run 'sudo bash basic.sh'\n\n"

log_file_verbose="log_basic_verbose.txt"
log_file="log_basic.txt"
config_file="user.conf"
success=0
fails=0
source $config_file

install() {
  log_install ${1}
  pacman -Sy ${1} --noconfirm --verbose >> $log_file_verbose
  log_status ${2}
}

log_install () {
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
    printf "[FAIL]\n" >> $log_file
    fails=$((fails+1))
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
    echo "${1}=1" >> $config_file
  fi
}

create_restore_point(){
  add_config ${1}
  if [ ${!1} = "1" ]; then
    echo "[INFO] ${1} already exist, check 'sudo timeshift --list'"
  else
    timeshift --create --snapshot ${1} --comments ${2} --verbose >> $log_file_verbose    
  fi
}

user_interact(){
  echo "=-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-="
  echo "::: ${1}"
  echo "=-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-=  =-=-="
  read user_answer
}

# Update Pacman
pacman -Syu --noconfirm

# Timeline Restorer
install timeshift

# Restore point creation
create_restore_point "born_point" "Initial installation of the operating system"

# Web Navigator Vivaldi
log_install Vivaldi
su -c "pamac build vivaldi --noconfirm >> $log_file_verbose"
log_status

# Vim terminal text editor
install vim

# Main text editor for Visual Studio Code development
install code

# Java JRE and JDK
install jre-openjdk
install jdk-openjdk

# Telegram
install telegram-desktop

# Mouse support [!] Need Reboot [!]
install xf86-input-synaptics input_driver

# Restore point post install
create_restore_point "basic" "Basic user toolkit installed"

if [ $input_driver -ne 1 ]; then
  user_interact "Need to reboot. Want do this now? [y/n]"
  if [ $user_answer = "y" -o $user_answer = "s" ]; then
    log_install reboot
    log_status reboot
    reboot
  fi
fi

echo "##########################################" >> $log_file
printf "##########################################\n" >> $log_file_verbose
log_finish
