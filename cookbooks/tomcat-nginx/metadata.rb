name             'tomcat-nginx'
maintainer       'Megam Systems'
maintainer_email 'subash.avc@gmail.com'
license          'All rights reserved'
description      'Installs/Configures tomcat-nginx'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'


depends "nginx"
depends "apt"
