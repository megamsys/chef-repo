		cd auth-keys
		sudo chown postgres.postgres authorized_keys id_rsa.pub id_rsa
		sudo mkdir -p ~postgres/.ssh
		sudo chown postgres.postgres ~postgres/.ssh
		sudo mv authorized_keys id_rsa.pub id_rsa ~postgres/.ssh
		sudo chmod -R go-rwx ~postgres/.ssh
