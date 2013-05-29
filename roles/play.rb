name "play"
description "play role installs and configures play app on nginx"
run_list "recipe[megam_play]"

override_attributes(
  :myroute53 => {
    :name => "api"
  } 
)

