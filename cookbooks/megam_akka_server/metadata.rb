name             'megam_akka_server'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'All rights reserved'
description      'Installs/Configures megam_akka'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "megam_deps"
depends "git"
depends "megam_route53"
depends "apt"
depends "megam_logstash"


