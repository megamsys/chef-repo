name             'megam_deps'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          "Apache 2.0"
version          '0.5.0'
description      'Gets assembly data from riak and loads it in attributes'


#depends "megam_call"

depends "megam_nginx"
depends "megam_tomcat"


depends "megam_java"
recommends "megam_akka"
recommends "megam_play"
recommends "megam_rails"
depends "megam_nodejs"
depends "megam_docker"
depends "megam_sqlite3"

depends "megam_riak"
depends "megam_redis2"
recommends "megam_postgresql"
recommends "megam_rabbitmq"

recommends "megam_op5"
recommends "megam_zarafa"
recommends "megam_wordpress"

recommends "megam_backup"
recommends "megam_drbd"
