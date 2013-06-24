whoami
		ssh-keygen -t rsa -f /var/lib/postgresql/.ssh/id_rsa -P ""
		cat /var/lib/postgresql/.ssh/id_rsa.pub >> /var/lib/postgresql/.ssh/authorized_keys
		chmod go-rwx /var/lib/postgresql/.ssh/*

cd /var/lib/postgresql/.ssh/

zip auth-keys.zip id_rsa.pub id_rsa authorized_keys

cd /var/lib/postgresql/

ruby s3-put.rb
