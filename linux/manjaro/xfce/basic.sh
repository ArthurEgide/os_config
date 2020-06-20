printf "\n\n\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n"
echo "Author: Arthur da Silva Egide"
echo "Contact: arthuregide@gmail.com"
echo "Linkedin: linkedin.com/in/arthuregide"
printf "\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n\n\n\n\n"

log_file_verbose="log_basic_verbose.txt"
log_file="log_basic.txt"

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
  else
    printf "[FAIL]\n" >> $log_file
  fi

}

# Restaurador de linha do tempo
install timeshift


# Criação de ponto de restauração
# timeshift --create --snapshot "born_point" --comments "Instalação inicial do sistema operacional" --verbose >> $log_file_verbose

# Editor de texto em terminal Vim
install vim
