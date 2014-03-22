name "wordpress"
description "Wordpress role installs wordpress, configuration has to be made manually"
run_list "recipe[megam_wordpress]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu", "sandbox"],
      :passwordless => true
    }
  }
)

