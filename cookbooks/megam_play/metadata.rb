name             'megam_play'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'All rights reserved'
description      'Installs/Configures megam_play'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apt"
depends "megam_deps"
depends "megam_ganglia"
depends "megam_logstash"
depends "nginx"
depends "megam_route53"
depends "megam_sandbox"
depends "megam_gulp"
