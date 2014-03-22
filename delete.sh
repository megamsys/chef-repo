#!/bin/bash
#EXECUTION COMMAND
#sh test.sh prescribed1.megam.co monumental1.megam.co debacle1.megam.co
for i in $*; do
    echo $i
    knife ec2 server delete `knife search node name:$i -a megam.instanceid | grep megam.instanceid | awk '{print $2}'` -N $i -P -y
done

mobutu1.megam.co

knife ec2 server delete `knife search node name:mobutu1.megam.co -a megam.instanceid | grep megam.instanceid | awk '{print $2}'` -N mobutu1.megam.co -P -y
