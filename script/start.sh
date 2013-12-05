#IMAGES
	#JAVA+RUBY ami-a0074df2
	#RUBY ami-8e074ddc

#knife ec2 server create --groups megam --image ami-8e074ddc --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'role[postgres_server_master]' -N postgres-server

#knife ec2 server create --groups megam --image ami-8e074ddc --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_riak_server]' -N riak-server

#knife ec2 server create --groups megam --image ami-a0074df2 --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_zookeeper]' -N zookeeper

#knife ec2 server create --groups megam --image ami-a0074df2 --flavor m1.small --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_snowflake]' --json-attributes '{ "megam_version": "0.1" }' -N snowflake

knife ec2 server create --groups megam --image ami-a0074df2 --flavor m1.small --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_play_server]' -N api-server

knife ec2 server create --groups megam --image ami-8e074ddc --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_rabbitmq_server]' -N rabbitmq-server

knife ec2 server create --groups megam --image ami-8e074ddc --flavor m1.small --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'role[redis_server_master]' -N redis-server

knife ec2 server create --groups megam --image ami-8e074ddc --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_nodejs_server]' -N nodejs-server

#knife ec2 server create --groups megam --image ami-a0074df2 --flavor m1.small --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_akka_server]' -N akka-server

knife ec2 server create --groups megam --image ami-8e074ddc --flavor t1.micro --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_ganglia::gmetad]' -N gmetad

#knife ec2 server create --groups megam --image ami-8e074ddc --flavor m1.large --ssh-key megam_ec2 --identity-file ~/.ssh/megam_ec2.pem --ssh-user ubuntu --run-list 'recipe[megam_rails_server]' -N rails-server

