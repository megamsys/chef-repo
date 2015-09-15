name             "megam_hadoop"
maintainer       "Megam Systems"	
maintainer_email "ranjithar@megam.io"
license          "Apache 2.0"
description      "Installs/Configures read"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

#depends "apt"

%w{ debian ubuntu }.each do |os|
  supports os
end

