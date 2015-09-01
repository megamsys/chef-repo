name             "megam_logging"
maintainer       "Megam Systems"
maintainer_email "thomasalrin@megam.io"
license          "Apache 2.0"
version          '0.5.0'
description      "Installs/Configures packages for logging"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))


%w{ ubuntu debian redhat centos scientific amazon fedora }.each do |os|
  supports os
end

%w{ build-essential yumrepo }.each do |ckbk|
  depends ckbk
end

depends "megam_preinstall"

%w{ yumrepo apt }.each do |ckbk|
  recommends ckbk
end
