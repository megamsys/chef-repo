name             'megam_rails'
maintainer       'Devops Israel'
maintainer_email 'evgeny@devops.co.il'
license          'All rights reserved'
description      'Installs/Configures megam_rails'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.3'

depends "git"
#depends "ruby"
depends "nginx", ">= 1.2.1" # uses nginx version 1.2.6
depends "unicorn"
depends "application", ">= 2.0.2"
depends "application_ruby"
depends "application_nginx"
depends "runit"
depends "chef-solo-search"
depends "megam_nginx"
depends "megam_route"
# to use the rails_application::database_credentials recipe
recommends "database"
depends "megam_environment"
depends "megam_preinstall"

