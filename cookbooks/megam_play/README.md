megam_play Cookbook
===================
This cookbook is to get Nginx to serve as a proxy server for Play framework applications

Requirements
------------
The following Opscode cookbooks are dependencies:

* apt
* nginx
* megam_route53


Usage
-----
To use this cookbook, Just include `megam_play` in your node's `run_list`:

```run_list "recipe[megam_play]"
```

License and Author
==================

Author:: Kishore Kumar (<nkishore@megam.co.in>)
Author:: Thomas Alrin (<alrin@megam.co.in>)


Copyright:: 2013, Megam Systems

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
