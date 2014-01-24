name "redis"
description "redis role installs and configures redis"
run_list "recipe[runit@0.15.0]", "recipe[megam_redis2::master]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

