name "drbd-slave"
description "Configure DRBD for secondary setup"
run_list "recipe[megam_drbd]"

override_attributes(
  :drbd => {
    :remote_host => "d11.megam.co"
  }
)

