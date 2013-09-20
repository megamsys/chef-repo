name "rails"
description "deploy rails application"
run_list "recipe[megam_rails_application]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

