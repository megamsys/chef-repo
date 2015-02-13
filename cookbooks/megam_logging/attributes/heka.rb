#default['heka']['amqp_url'] = "www.megam.co"
#default['heka']['logs'] = {"queue1" => ["/var/log/sysog", "/var/log/auth.log"], "queue2" => ["/var/log/sysog", "/var/log/auth.log"]}

default['heka']['logs'] = {}

default['heka']['conf'] = "#{node['megam']['user']['conf']}/hekad.toml"

default['heka']['start'] = "#{node['megam']['user']['home']}/bin/heka"

default['heka']['log'] = "/var/log/megam/heka.log"

default['heka']['init'] = "/etc/init/heka.conf"

default['heka']['service'] = "/etc/systemd/system/heka.service"
