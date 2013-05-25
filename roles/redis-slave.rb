name "redis-slave"
description "redis role installs and configures redis"
run_list "recipe[runit@0.15.0]", "recipe[megam_redis2::slave]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

