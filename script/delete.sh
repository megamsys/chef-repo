
#knife ec2 server delete i-839455aa -y -P -N nodejs-server

#knife search node name:api-server -a ec2.instance_id

knife ec2 server delete `knife search node name:riak-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N riak-server -P -y
knife ec2 server delete `knife search node name:zookeeper -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N zookeeper -P -y
knife ec2 server delete `knife search node name:snowflake -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N snowflake -P -y
knife ec2 server delete `knife search node name:api-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N api-server -P -y
knife ec2 server delete `knife search node name:rabbitmq-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N rabbitmq-server -P -y
knife ec2 server delete `knife search node name:redis-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N redis-server -P -y
knife ec2 server delete `knife search node name:nodejs-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N nodejs-server -P -y
knife ec2 server delete `knife search node name:gmetad -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N gmetad -P -y
knife ec2 server delete `knife search node name:postgres-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N postgres-server -P -y
#knife ec2 server delete `knife search node name:rails-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N zookeeper -P -y
#knife ec2 server delete `knife search node name:api-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N zookeeper -P -y
#knife ec2 server delete `knife search node name:api-server -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N zookeeper -P -y



