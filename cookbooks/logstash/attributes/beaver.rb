
default['logstash']['beaver']['pip_package'] = "beaver==22"
default['logstash']['beaver']['zmq']['pip_package'] = "pyzmq==2.1.11"
default['logstash']['beaver']['server_role'] = "logstash_server"
default['logstash']['beaver']['server_ipaddress'] = "#{node['logstash']['redis_url']}"

default['logstash']['beaver']['redis_url'] = "redis://#{node['logstash']['redis_url']}:6379/0"

default['logstash']['beaver']['git_cmd'] = "sudo pip install git+git://github.com/indykish/beaver.git"

default['logstash']['beaver']['inputs'] = [ "/var/log/nginx/*.log" ]
default['logstash']['beaver']['output'] = "redis"
default['logstash']['beaver']['format'] = "json"

default['logstash']['beaver']['logrotate']['options'] = [ 'missingok', 'notifempty', 'compress', 'copytruncate' ]
default['logstash']['beaver']['logrotate']['postrotate'] = 'invoke-rc.d logstash_beaver force-reload >/dev/null 2>&1 || true'
