name "rabbitmq-master"
description "installs and configures rabbitmq"
run_list "recipe[megam_rabbitmq]"


=begin
override_attributes(
  :myroute53 => {
    :name => "rabbitmq2"
  }
)
=end
