#
# Cookbook Name:: core-couchdb
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node[:platform]
when "Debian", "ubuntu"
if File.exist?('/usr/local/bin/couchdb')

template "/usr/local/etc/couchdb/default.ini" do
source "default.ini.erb"
end

execute "service couchdb restart"
else

execute "apt-get update"

execute "apt-get install --yes build-essential curl git"

execute "apt-get install --yes python-software-properties python g++ make"

execute "sudo apt-get install -y erlang-dev erlang-manpages erlang-base-hipe erlang-eunit erlang-nox erlang-xmerl erlang-inets"

execute "apt-get install -y libmozjs185-dev libicu-dev libcurl4-gnutls-dev libtool"

execute "install couchdb" do
command "wget http://ftp.fau.de/apache/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz"
end

execute "tar xvzf apache-couchdb-*"

bash 'make' do
  code <<-EOH
    cd apache-couchdb-*
      ./configure && make
     make install
  EOH
  ignore_failure true
end

if !(File.exist?('/usr/local/bin/couchdb'))
  bash 'make' do
    code <<-EOH
      cd apache-couchdb-*
        ./configure && make
       make install
    EOH
  end
end

execute "add user" do
  command "useradd -d /var/lib/couchdb couchdb"
end

bash 'permission' do
  code <<-EOH
    chown -R couchdb: /usr/local/var/{lib,log,run}/couchdb /usr/local/etc/couchdb
    chmod 0770 /usr/local/var/{lib,log,run}/couchdb/
     chmod 664 /usr/local/etc/couchdb/*.ini
      chmod 775 /usr/local/etc/couchdb/*.d
  EOH
end

bash 'make' do
  code <<-EOH
    cd /etc/init.d
   ln -s /usr/local/etc/init.d/couchdb couchdb
  EOH
end

execute "start " do
command "/etc/init.d/couchdb start"
end

execute "update-rc.d couchdb defaults"

template "/usr/local/etc/couchdb/default.ini" do
source "default.ini.erb"
end

execute "service couchdb restart"
end
end
