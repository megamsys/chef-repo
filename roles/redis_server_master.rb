name "redis_server_master"
description "redis role installs and configures redis"
run_list "recipe[runit@0.15.0]", "recipe[megam_redis2_server::master]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

