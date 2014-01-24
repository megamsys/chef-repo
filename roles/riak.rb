name "riak"
description "riak role installs and configures riak"
run_list "recipe[megam_riak]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["sandbox"],
      :passwordless => true
    }
  }
)

