name "postgres-standby"
description "A PostgreSQL Standby"
run_list "recipe[megam_postgresql::server]"

override_attributes(
  :postgresql => {
    :standby => true,
    :hot_standby => "on",
    :master_ip => "10.130.147.120"
  },
  :myroute53 => {
    :name => "postgres2"
  }
)
