default[:zookeeper] = {
  :jvm_opts    => "-Djava.net.preferIPv4Stack=true",
  :client_port => 2181,
  :servers     => ["server.1=zoo1.megam.co.in:2888:3888", "server.2=zoo2.megam.co.in:2888:3888", "server.3=zoo3.megam.co.in:2888:3888"]
}
