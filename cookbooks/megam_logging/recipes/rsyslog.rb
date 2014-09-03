#
# Cookbook Name:: megam_logging
# Recipe:: rsyslog
#
#

#rsyslog template
case node[:platform]
when "debian"

bash "Install Rsyslog" do
  user "root"
   code <<-EOH
cd /tmp
wget http://www.rsyslog.com/files/download/rsyslog/rsyslog-7.4.4.tar.gz
wget http://libestr.adiscon.com/files/download/libestr-0.1.9.tar.gz
wget http://www.libee.org/files/download/libee-0.4.1.tar.gz

apt-get -y install gcc make pkg-config libjson0-dev uuid-dev libcurl4-openssl-dev python-docutils bison flex

tar xzf libestr-0.1.9.tar.gz
tar xzf libee-0.4.1.tar.gz
tar xzf rsyslog-7.4.4.tar.gz

cd /tmp/libestr-0.1.9
./configure --libdir=/usr/lib --includedir=/usr/include --enable-rfc3195
make 
make install

cd /tmp/libee-0.4.1
./configure --libdir=/usr/lib --includedir=/usr/include
make 
make install

cd /tmp/rsyslog-7.4.4
./configure --prefix=/usr --enable-imfile --enable-elasticsearch
make
make install
  EOH
end

when "ubuntu"

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

#=begin
when "redhat", "centos", "fedora"

#package "openjdk-7-jre"
execute "yum -y install java-1.7.0-openjdk.x86_64"

bash "Install Libestr" do
  user "root"
   code <<-EOH
   yum install -y pcre pcre-devel mysql-server mysql-devel gnutls gnutls-devel gnutls-utils net-snmp net-snmp-devel net-snmp-libs net-snmp-perl net-snmp-utils libnet libnet-devel libxml2-devel.x86_64
   
   cd /tmp
wget http://sourceforge.net/projects/libestr/files/libestr-0.1.0.tar.gz/download
tar -xvf libestr-0.1.0.tar.gz
cd libestr-0.1.0
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
EOH
end

bash "Install libee" do
  user "root"
   code <<-EOH
cd /tmp
wget http://www.libee.org/files/download/libee-0.1.0.tar.gz
tar -xvf libee-0.1.0.tar.gz
cd libee-0.1.0
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
EOH
end

bash "Install relp" do
  user "root"
   code <<-EOH
   
cd /tmp
wget http://download.rsyslog.com/librelp/librelp-1.0.0.tar.gz
tar -xvf librelp-1.0.0.tar.gz
cd librelp-1.0.0
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
EOH
end

if `rpm -qa | grep libnet`.to_s.strip.length == 0
bash "Install Libnet" do
  user "root"
   code <<-EOH
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libnet-1.1.6-7.el6.x86_64.rpm
rpm -ivh libnet-1.1.6-7.el6.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libnet-devel-1.1.6-7.el6.x86_64.rpm
rpm -ivh libnet-devel-1.1.6-7.el6.x86_64.rpm
  EOH
end
end

bash "Install Rsyslog" do
  user "root"
   code <<-EOH
cd /tmp
wget http://www.rsyslog.com/files/download/rsyslog/rsyslog-5.7.9.tar.gz
tar -xvf rsyslog-5.7.9.tar.gz
cd rsyslog-5.7.9 
./configure --enable-regexp --enable-zlib --enable-pthreads --enable-klog --enable-inet --enable-unlimited-select --enable-debug --enable-rtinst --enable-memcheck --enable-diagtools --enable-mysql --enable-snmp --enable-gnutls --enable-rsyslogrt --enable-rsyslogd --enable-extended-tests --enable-mail --enable-imptcp --enable-omruleset --enable-valgrind --enable-imdiag --enable-relp --enable-testbench --enable-imfile --enable-omstdout --enable-omdbalerting --enable-omuxsock --enable-imtemplate --enable-omtemplate --enable-pmlastmsg --enable-omudpspoof --enable-omprog --enable-impstats
make
make install 
  EOH
end
#=end

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
