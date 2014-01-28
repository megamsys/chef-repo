name "play"
description "play role installs and configures play app on nginx"
run_list "recipe[megam_play]"
override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu", "sandbox"],
      :passwordless => true
    }
  }
)
