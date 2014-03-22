#
# Cookbook Name:: megam_logstash
# Recipe:: rsyslog
#
#

#rsyslog template

bash "Install Rsyslog" do
  user "root"
   code <<-EOH
cd /tmp
wget http://www.rsyslog.com/files/download/rsyslog/rsyslog-7.4.4.tar.gz
wget http://libestr.adiscon.com/files/download/libestr-0.1.9.tar.gz
wget http://www.libee.org/files/download/libee-0.4.1.tar.gz

sudo apt-get -y install gcc make pkg-config libjson0-dev uuid-dev libcurl4-openssl-dev python-docutils bison flex

tar xzf libestr-0.1.9.tar.gz
tar xzf libee-0.4.1.tar.gz
tar xzf rsyslog-7.4.4.tar.gz

cd /tmp/libestr-0.1.9
./configure --libdir=/usr/lib --includedir=/usr/include --enable-rfc3195
sudo make 
sudo make install

cd /tmp/libee-0.4.1
./configure --libdir=/usr/lib --includedir=/usr/include
sudo make 
sudo make install

cd /tmp/rsyslog-7.4.4
./configure --prefix=/usr --enable-imfile --enable-elasticsearch
sudo make
sudo make install
  EOH
end

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end


execute "Restart Rsyslog" do
  command "sudo service rsyslog restart"
end
