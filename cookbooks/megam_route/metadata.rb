name             'megam_route'
maintainer       'Megam Systems'
maintainer_email 'thomasalrin@megam.io'
license          "Apache 2.0"
version          '0.5.0'
description      'Gets assembly data from riak and loads it in attributes'

depends "megam_nginx"
depends "megam_tomcat"

depends "ghost-blog"

depends "megam_spark"
depends "megam_hadoop"
depends "megam_spark_notebook"

depends "megam_java"
depends "application_php"
depends "megam_play"
depends "megam_rails"
depends "megam_nodejs"
depends "megam_docker"

depends "megam_mysql"
depends "megam_riak"
depends "megam_redis2"
depends "megam_postgresql"
depends "megam_rabbitmq"

recommends "megam_op5"
recommends "owncloud"
recommends "wordpress"


#recommends "megam_backup"
#recommends "megam_drbd"
