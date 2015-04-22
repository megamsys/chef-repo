name             'megam_akka'
maintainer       'Megam Systems'
maintainer_email 'thomasalrin@megam.io'
license          'Apache 2.0'
version          '0.5.0'
description      'Installs/Configures megam_akka'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

depends "megam_metering"
depends "git"
depends "megam_deps"
depends "megam_logging"
depends "megam_gulp"
depends "megam_environment"
depends "megam_preinstall"
depends "megam_start"


