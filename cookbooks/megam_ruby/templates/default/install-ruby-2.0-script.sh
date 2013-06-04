
#Source https://github.com/Raybeam/rb_base/blob/master/setup.sh
sudo apt-get -y update

sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl1.0.0 libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion nodejs

# Install ruby 2.0

cd /tmp
  wget -nv ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p195.tar.gz
  tar zxvf ruby-2.0.0-p195.tar.gz
  cd ruby-2.0.0-p195
./configure --with-openssl-dir=/usr/local/openssl; make; sudo make install

sudo gem update -f -q
sudo gem install bundler
