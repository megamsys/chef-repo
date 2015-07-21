name             'megam_rails'
maintainer       'Megam Systems'
maintainer_email 'thomasalrin@megam.io'
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
depends "runit"
depends "megam_metering"
depends "megam_nginx"
depends "git"
depends "megam_deps"

# to use the rails_application::database_credentials recipe
recommends "database"
