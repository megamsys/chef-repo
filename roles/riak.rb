name "riak"
description "riak role installs and configures riak"
run_list "recipe[riak]"

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu"],
      :passwordless => true
    }
  }
)

