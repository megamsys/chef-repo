name             'mariadb'
maintainer       'Megam Systems'
maintainer_email 'ranjithar@megam.io'
license          'Apache 2.0"'
description      'Installs/Configures MariaDB'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.1'

depends "apt", ">= 0.0.0"
depends "yum", ">= 0.0.0"
depends "yum-epel", ">= 0.0.0"

