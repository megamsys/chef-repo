name "tomcat-openam"
description "tomcat-openam role installs and configures tomcat and openam"
run_list "recipe[megam_tomcat-openam]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

