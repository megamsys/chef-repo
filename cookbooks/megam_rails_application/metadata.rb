name             'megam_rails_application'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'All rights reserved'
description      'Installs/Configures rails_application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

depends "git"
depends "apt"
depends "nginx"
depends "unicorn"
depends "application"
depends "application_ruby"
depends "application_nginx"
depends "megam_deps"
depends "megam_ciakka"
depends "megam_ganglia"
depends "megam_route53"
depends "logstash"



# to use the rails_application::database_credentials recipe
recommends "database"
