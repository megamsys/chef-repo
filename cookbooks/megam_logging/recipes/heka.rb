#
# Cookbook Name:: megam_logging
# Recipe:: heka
#
#

#rsyslog template

template node['heka']['conf'] do
  source "hekad.toml.erb"
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
end

directory "/var/log/megam" do
  owner 'root'
  group 'root'
  action :create
end

case node[:platform]
when "ubuntu"

execute "add-apt-repository 'deb http://get.megam.co/0.5/ubuntu/ trusty testing'"
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv B3E0C1B7"
execute "apt-get -y update"
execute "apt-get -y install heka"

heka_start = "hekad"

template node['heka']['start'] do
  source "heka.erb"
  variables( :hekad => "#{heka_start}" )
  owner node['megam']['default']['user']
  group node['megam']['default']['user']
  mode "0755"
end


template node['heka']['init'] do
  source "hekad_init.conf.erb"
end

execute "Start heka" do
  command "sudo start heka"
end

when "centos"

yum_package "wget" do
  action :install
end


remote_file "/usr/bin/gulpd" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/hekad"
  mode '0755'
end


template node['heka']['service'] do
  source "heka.service.erb"
end

execute "systemctl enable heka.service"

execute "systemctl start heka.service"

end



