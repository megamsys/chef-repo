name             'megam_rails'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'All rights reserved'
description      'Installs/Configures rails_application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

#depends "nginx"
depends "unicorn"
depends "application"
depends "application_ruby"
depends "application_nginx"

depends "megam_metering"
depends "megam_nginx"
depends "git"
depends "megam_deps"
depends "megam_logging"
depends "megam_gulp"
depends "megam_environment"
depends "megam_preinstall"
depends "megam_start"


depends "megam_ruby"




# to use the rails_application::database_credentials recipe
recommends "database"
