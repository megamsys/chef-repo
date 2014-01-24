#!/bin/bash
#EXECUTION COMMAND
#sh test.sh prescribed1.megam.co monumental1.megam.co debacle1.megam.co
for i in $*; do
    echo $i
    knife ec2 server delete `knife search node name:$i -a ec2.instance_id | grep ec2.instance_id | awk '{print $2}'` -N $i -P -y
done
