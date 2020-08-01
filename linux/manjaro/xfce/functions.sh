source "${OS_CONFIG}/user.conf"

if [ ${1} ];
  then from=${1};
  else from=0; # Default 1. User using functions!
fi

from() {
  if [ $from -eq 0 ];
  then echo "user";
  else echo "script";
  fi
}

install() {
  log_base ${1} install
  pacman -Sy ${1} --noconfirm --verbose >> $log_file_verbose
  log_status ${2}
}

remove(){
  
  if [ $from -eq 0 ];
  then
    log_base ${1} remove
    sudo pacman -Rsu ${1} --noconfirm >> $log_file_verbose
    log_status ${1} "remove"
  else
    if [ ${!1} = "1" ]; 
    then
      log_base ${1} remove
      sudo pacman -Rsu ${2} --noconfirm >> $log_file_verbose
      log_status ${2} "remove"
    fi
  fi
}

log_base () {

    if [ $from -eq 0 ];
    then 
      echo "=-=-=-=    ${USER} - ${2} - $(date)   =-=-=-=" >> $log_file
      printf "## ${1} " >> $log_file

      echo "=-=-=-=     ${USER} - ${2} - $(date)   =-=-=-=" >> $log_file_verbose
      printf "## ${1} " >> $log_file_verbose
    else
        echo "##########################################" >> $log_file
        printf "## ${1} " >> $log_file

        echo "##########################################" >> $log_file_verbose
        printf "## ${1} " >> $log_file_verbose
    fi
  
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
  echo "$(date)" >> $log_file
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
