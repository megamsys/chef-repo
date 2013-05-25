name "opendj"
description "opendj role installs and configures opendj"
run_list "recipe[megam_opendj-openam]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

