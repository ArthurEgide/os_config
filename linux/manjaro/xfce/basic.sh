printf "\n\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"
echo "Author: Arthur da Silva Egide"
echo "Contact: arthuregide@gmail.com"
echo "Linkedin: linkedin.com/in/arthuregide"
printf "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n\n\n\n"
printf " You need to run with adminstrator permissions. Run 'sudo bash basic.sh'\n\n"

log_file_verbose="log_basic_verbose.txt"
log_file="log_basic.txt"
success=0
fails=0

install() {
  log_install ${1}
  pacman -Sy ${1} --noconfirm --verbose >> $log_file_verbose
  log_status
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

# Update Pacman
log_install Pacman_Update
pacman -Syu --noconfirm
log_status Pacman_Update

# Web Navigator Vivaldi
log_install Vivaldi
su -c "pamac build vivaldi --noconfirm >> $log_file_verbose"
log_status

# Timeline Restorer
install timeshift

# Restore point creation
timeshift --create --snapshot "born_point" --comments "Initial installation of the operating system" --verbose >> $log_file_verbose

# Vim terminal text editor
install vim

# Main text editor for Visual Studio Code development
install code

# Java
install jre-openjdk
install jdk-openjdk

echo "##########################################" >> $log_file
printf "##########################################\n" >> $log_file_verbose
log_finish
