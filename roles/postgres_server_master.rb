name "postgres_server_master"
description "A PostgreSQL Master"
run_list "recipe[megam_postgresql_server::server]"

override_attributes(
  :postgresql => {
    :password => "team4megam",
    :dbname => "cocdb",
    :db_main_user => "megam",
    :db_main_user_pass => "team4megam",
  }
)

