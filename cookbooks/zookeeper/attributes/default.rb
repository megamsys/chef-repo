default[:zookeeper] = {
  :jvm_opts    => "-Djava.net.preferIPv4Stack=true",
  :client_port => 2181,
  :servers     => []
}
