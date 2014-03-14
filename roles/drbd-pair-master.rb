name "drbd-pair-master"
description "DRBD pair role."

override_attributes(
  "drbd" => {
    "remote_host" => "ghost1.megam.co",
    "disk" => "/dev/vda1",
    "mount" => "/srv",
    "master" => true
  }
  )

run_list(
  "recipe[drbd::pair]"
  )
