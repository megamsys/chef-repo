name "op5"
description "op5 role installs and configures op5-monitor"
run_list "recipe[megam_op5]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu", "sandbox"],
      :passwordless => true
    }
  }
)

