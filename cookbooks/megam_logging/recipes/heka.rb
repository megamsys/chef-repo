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

case node[:platform]
when "ubuntu"

#MEGAM IAAS Image already installed with heka
=begin
#add-apt package support
package "software-properties-common"

execute "add-apt-repository 'deb [arch=amd64] http://get.megam.io/0.8/ubuntu/14.04/ testing megam'"
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv B3E0C1B7"
execute "apt-get -y update"
execute "apt-get -y install heka"
=end

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


remote_file "/usr/bin/hekad" do
  source "https://s3-ap-southeast-1.amazonaws.com/megampub/chef/hekad"
  mode '0755'
end


template node['heka']['service'] do
  source "heka.service.erb"
end

execute "systemctl enable heka.service"

execute "systemctl start heka.service"

end



