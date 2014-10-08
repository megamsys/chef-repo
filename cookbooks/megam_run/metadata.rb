name             'megam_run'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          "Apache 2.0"
version          '0.5.0'
description      'starting cookbook megam_run'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))


depends "megam_preinstall"
depends "megam_dns"
depends "megam_deps"
depends "megam_gulp"
depends "megam_metering"
depends "megam_logging"
depends "megam_environment"
