name "nodejs"
description "nodejs role installs and configures nodejs"
run_list "recipe[megam_nodejs]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

