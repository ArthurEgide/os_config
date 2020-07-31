touch user.conf
chmod 777 user.conf

echo log_file_verbose="log_debug.txt" > user.conf
echo log_file="log.txt" >> user.conf

# Todas as funções utilizadas, para ficar mais limpo o código
source "functions.sh"
source "status.txt"
source "user.conf"

touch $log_file $log_file_verbose
chmod 777 $log_file $log_file_verbose

# Before Super User command
# Web Navigator Vivaldi
log_base Vivaldi
#su -c "pamac build vivaldi --no-confirm >> $log_file_verbose"
pamac build vivaldi --no-confirm >> $log_file_verbose
log_status web_browser

sudo bash basic.sh $USER
