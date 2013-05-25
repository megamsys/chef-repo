name "rabbitmq-slave"
description "installs and configures rabbitmq"
run_list "recipe[megam_rabbitmq]"


override_attributes(
  :rabbitmq => {
    :cluster => true,
    :cluster_node_type => 'ram'
  } ,

  :myroute53 => {
    :name => "rabbitmq2"
  }

)

