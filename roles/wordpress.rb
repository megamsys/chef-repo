name "wordpress"
description "Wordpress role installs wordpress, configuration has to be made manually"
run_list "recipe[wordpress]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

