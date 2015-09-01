name             'megam_play'
maintainer       'Megam Systems'
maintainer_email 'thomasalrin@megam.io'
license          'All rights reserved'
description      'Installs/Configures megam_play'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "megam_deps"
depends "megam_logging"
depends "nginx"
depends "megam_preinstall"

