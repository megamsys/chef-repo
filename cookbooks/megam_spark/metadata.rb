name             "megam_spark"
maintainer       "Megam Systems"
maintainer_email "ranjithar@megam.io"
license          "All rights reserved"
description      "Installs/Configures spark"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

#depends 'apt'
%w{  debian Ubuntu }.each do |os|
 supports os
end
