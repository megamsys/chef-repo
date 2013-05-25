name "postgres-master"
description "A PostgreSQL Master"
run_list "recipe[megam_postgresql::server]"

override_attributes(
  :postgresql => {
    :master => true,
    :wal_level => "hot_standby",
    :max_wal_senders => 5,
    :standby_ips => [ "postgres2.megam.co.in"]
  },
  :myroute53 => {
    :name => "postgres1"
  }
)

