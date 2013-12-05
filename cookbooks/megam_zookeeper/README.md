# ZooKeeper Chef Cookbook

This is a lightweight OpsCode Chef cookbook for Apache ZooKeeper that supports
Ubuntu and Debian.

It uses standard apt repository packages, allows you to tweak JVM and `zoo.cfg` parameters
using Chef node attributes and is intentionally small, simple and limited in scope.


## ZooKeeper Version

This cookbook uses standard apt packages so the exact version will vary between distribution
releases. For [recent Ubuntu releases](packages.ubuntu.com/zookeeper), it is ZooKeeper 3.3.


## Recipes

Main recipe is `zookeeper::default`.


## Attributes

All the attributes below are namespaced under `node[:zookeeper]`, so `:jvm_opts` is accessible
via `node[:zookeeper][:jvm_opts]` and so on.

* `:jvm_opts`: command line switches that will be passed to JVM on server start (like `-Djava.net.preferIPv4Stack`)
* `:client_port`: port ZooKeeper clients will use to connect, 2181 by default
* `:servers`: a list of server lines as accepted in ZooKeeper configuration file, empty by default.


## Dependencies

OpenJDK 6 or Sun JDK 6.


## Copyright & License

Michael S. Klishin & Orceo GmbH, 2012.

Released under the [Apache 2.0 license](http://www.opensource.org/licenses/Apache-2.0).
