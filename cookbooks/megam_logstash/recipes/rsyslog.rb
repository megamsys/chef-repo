#
# Cookbook Name:: megam_logstash
# Recipe:: rsyslog
#
#

#rsyslog template

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end


execute "Restart Rsyslog" do
  command "sudo service rsyslog restart"
end
