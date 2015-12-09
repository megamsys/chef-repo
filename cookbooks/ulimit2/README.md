ulimit2 Cookbook
===============
A cookbook to set resource limits via ulimit.

Requirements
------------
Ruby 1.9 or later

Should support any linux platform, but has been tested successfully on:

  - rhel >= 5.0
  - centos >= 5.0
  - fedora >= 17.0
  - debian >= 6.0
  - ubuntu >= 12.04

Attributes
----------

#### ulimit2::default

*  **['ulimit']['conf\_dir']**  
    _Type:_ String  
    _Description:_ The directory to store the config file in  
    _Default:_ /etc/security/limits.d

*  **['ulimit']['conf\_file']**  
    _Type:_ String  
    _Description:_ The file containing the resource limits  
    _Default:_ 999-chef-ulimit.conf

Usage
-----

#### ulimit2::default
Set attributes in the ulimit/params namespace to set resource limits.  Example values:

    node.set['ulimit']['params']['default']['nofile'] = 2000 # Set hard and soft open file limit to 2000 for all users
    node.set['ulimit']['params']['default']['nproc']['soft'] = 2000 # Set the soft per-user process limit to 2000 for all users
    node.set['ulimit']['params']['root']['nofile']['soft'] = 8000   # Set the soft open file limit to 8000 for the 'root' user
    node.set['ulimit']['params']['root']['nofile']['hard'] = 'unlimited' # Set the hard open file limit to unlimited for the 'root' user
    node.set['ulimit']['params']['@sysadmin']['nproc']['hard'] = 2500  # Set the hard process limit to 2500 for the 'sysadmin' group

Then, just include `ulimit2` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[ulimit2]"
  ]
}
```

For systems that don't support individual configuration files, meaning they only support settings in the /etc/security/limits.conf, set ulimit/conf\_dir attribute to '/etc/security' and ulimit/conf\_file attribute to 'limits.conf'; or whatever setting is appropriate to your system.

The default ulimit/conf\_file attribute value gives us a reasonable chance of being the last config file applied.  The files are processed according to their ASCII sort order, so there is still room to add more files to be processed after the recipe default file by naming the config file with leading character prefixes (ex. zzz-last.conf).

License and Authors
-------------------

Authors: Michael Morris  
License: 3-clause BSD
