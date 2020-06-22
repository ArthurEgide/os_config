source "user.conf"
pacman -Rs $(pacman -Qdtq) --noconfirm


remove(){
  if [ ${!1} = "1" ]; then
    sudo pacman -Rsu ${2} --noconfirm
  fi
}

remove text_editor mousepad
remove terminal_text_editor nano
remove web_browser midori