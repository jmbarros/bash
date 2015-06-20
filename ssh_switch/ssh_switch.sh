#!/bin/bash
#ssh switch
#by jmbarros at tech4it.com.br
clear
echo -e "Choice your option (1 or 2 )/n?"
echo -e "	1) Create a temporary access..."
echo -e "	2) Exit!"

read INPUT

case $INPUT in

1)
echo "Username? (without spaces... pls!)"
read USERNAME
echo "E-mail Address? "
read EMAIL
clear
echo "The information below is correct?"
echo "Username: $USERNAME"
echo "E-mail: $EMAIL"
echo "Digit yes or no"
read INPUT2
	case $INPUT2 in

	yes)
	#create random password
	PASSWORD=`cat /dev/urandom|tr -dc "a-zA-Z0-9_\$\?"|fold -w 16|head -1`
	#crete home
	mkdir /mnt/ftp/home/$USERNAME
	#adding user
	adduser $USERNAME -d /mnt/ftp/home/$USERNAME -s /sbin/nologin -c $EMAIL 2> /dev/null
	echo "$USERNAME:$PASSWORD" | chpasswd
	#setting user expiration date
	chage -M 0 $USERNAME
       #set user to be removed after 1 day
       echo "#!/bin/bash" > /etc/cron.daily/$USERNAME
       echo "sed -i -e 's/$USERNAME//' /etc/vsftpd/user_list" >> /etc/cron.daily/$USERNAME
       echo "sed -i -e '/^$/d' /etc/vsftpd/user_list" >> /etc/cron.daily/$USERNAME
       echo "rm -rf /etc/cron.daily/$USERNAME" >> /etc/cron.daily/$USERNAME
       chmod +x /etc/cron.daily/$USERNAME

	#allow acess to vsftpd
	echo "$USERNAME" >> /etc/vsftpd/user_list

	#creating email message
	echo "to: $EMAIL" > /tmp/send_pass_msg.txt
	echo "from: system@tech4it.com.br" >> /tmp/send_pass_msg.txt
	echo "subject: [Não Responda] Sua Conta de FTP foi criada com sucesso" >> /tmp/send_pass_msg.txt
	echo "" >> /tmp/send_pass_msg.txt
	echo "Para acessar o FTP, uilize esse endereço:" >> /tmp/send_pass_msg.txt
	echo "ftp://$USERNAME:$PASSWORD@ftp.tech4it.com.br:8021" >> /tmp/send_pass_msg.txt
	echo "Caso o browser pergunte seu usuário e senha, eles são:" >> /tmp/send_pass_msg.txt
	echo "Usuário = $USERNAME" >> /tmp/send_pass_msg.txt
	echo "Password = $PASSWORD" >> /tmp/send_pass_msg.txt
	echo "" >> /tmp/send_pass_msg.txt
	echo "Essa senha expirará automaticamente em 1 dia, caso queira utilizá-la novamente me envie um e-mail!" >> /tmp/send_pass_msg.txt
	echo "JM" >> /tmp/send_pass_msg.txt

	#sending e-mail with passwd
	echo "Sending email to user..."
	/usr/sbin/ssmtp $EMAIL < /tmp/send_pass_msg.txt
	echo " OK"
	;;
	
	no)
	exit
	;;
	esac

;;
2)
echo "Confirm the email from user who you want change password"

exit
;;
3)
exit
;;
4)
echo "Exiting..."
exit
;;
esac
