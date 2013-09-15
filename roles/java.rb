name "java"
description "java role installs and configures maven, tomcat and orion"
run_list "recipe[megam_tomcat]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

