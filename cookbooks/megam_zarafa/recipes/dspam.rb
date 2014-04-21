
include_recipe "dspam"


node.set["clamav"]["clamd"]["tcp_socket"] = 3310
node.set["clamav"]["clamd"]["tcp_addr"] = "127.0.0.1"
node.set["clamav"]["clamd"]["enabled"] = true
include_recipe "clamav"

#template "/etc/dspam/dspam.conf"

template "/etc/postfix/dspam_filter_access" do
  notifies :restart, "service[postfix]"
end


template "/etc/postfix/master.cf" do
  notifies :restart, "service[postfix]"
end

##configure chrooted postfix
directory "/var/spool/postfix/var/run/dspam" do
  owner "dspam"
end

template "/etc/dspam/dspam.conf" do
  notifies :restart, "service[dspam]"
  notifies :restart, "service[postfix]"
end

