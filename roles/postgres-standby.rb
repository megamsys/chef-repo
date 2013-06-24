name "postgres-standby"
description "A PostgreSQL Standby"
run_list "recipe[megam_postgresql::server]"

override_attributes(
  :postgresql => {
    :standby => true,
    :password => 'team4megam',
    :dbname => "cocdb",
    :db_main_user => "mainuser",
    :db_main_user_pass => 'team4megam',
    :hot_standby => "on",
    :master_ip => "10.136.82.16"
  },
  :myroute53 => {
    :name => "postgres2"
  }
)
