name "drbd-master"
description "Configure DRBD for primary setup"
run_list "recipe[megam_drbd]"

override_attributes(
  :drbd => {
    :remote_host => "d21.megam.co",
    :source_dir => "/home/sandbox/ghost",
    :master => true
  }
)

