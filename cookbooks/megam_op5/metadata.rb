name             'megam_op5'
maintainer       'Megam Systems'
maintainer_email 'alrin@megam.co.in'
license          'All rights reserved'
description      'Installs/Configures megam_op5'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'


depends "megam_ganglia"
depends "apt"

depends "megam_route53"
depends "megam_deps"
depends "megam_logstash"
depends "megam_gulp"
depends "megam_app_env"
