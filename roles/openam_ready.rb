name "openam_ready"
description "openam role (installs common packages)"
run_list "recipe[tomcat-openam::configure]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

