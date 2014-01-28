name "redis"
description "redis role installs and configures redis"
run_list "recipe[runit]", "recipe[megam_redis2::master]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu", "sandbox"],
      :passwordless => true
    }
  }
)


