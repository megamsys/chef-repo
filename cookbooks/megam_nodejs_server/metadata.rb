maintainer       "Thomas Alrin(Megam Systems)"
maintainer_email "alrin@megam.co.in"
license          "Apache 2.0"
description      "Installs/Configures nodejs"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.4"
name             "megam_nodejs_server"
provides         "nodejs"



%w{ megam_route53 build-essential apt megam_deps megam_logstash}.each do |cookbooks|
  depends cookbooks
end

%w{ debian ubuntu centos redhat smartos }.each do |os|
    supports os
end
