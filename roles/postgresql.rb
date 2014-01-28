name "postgresql"
description "A PostgreSQL Master"
run_list "recipe[megam_postgresql::server]"
=begin
override_attributes(
  :postgresql => {
    :master => true,
    :password => "team4megam",
    :dbname => "cocdb",
    :db_main_user => "megam",
    :db_main_user_pass => "team4megam",
    :wal_level => "hot_standby",
    :max_wal_senders => 5,
    :standby_ips => [ "postgres2.megam.co.in"]
  },

  :myroute53 => {
    :name => "postgres1"
  }
)
=end

override_attributes(
  :authorization => {
    :sudo => {
      :users => ["ubuntu", "sandbox"],
      :passwordless => true
    }
  }
)
