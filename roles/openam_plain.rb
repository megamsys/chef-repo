name "openam_plain"
description "openam role (installs common packages)"
run_list "recipe[tomcat-openam::vanilla]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

