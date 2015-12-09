name 'ulimit2'
maintainer 'Michael Morris'
maintainer_email 'michael.m.morris@gmail.com'
license '3-clause BSD'
description 'Installs/Configures ulimit parameters'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

%w(redhat centos fedora ubuntu debian).each do |p|
  supports p
end

attribute 'ulimit/conf_dir',
          display_name: 'Config Dir',
          description: 'The name of the directory containing the ulimit settings file',
          type: 'string',
          required: 'required',
          recipes:  ['ulimit::default'],
          default:  '/etc/security/limits.d'

attribute 'ulimit/conf_file',
          display_name: 'Config File',
          description: 'The name of the file containing the ulimit settings',
          type: 'string',
          required: 'required',
          recipes:  ['ulimit::default'],
          default:  '999-chef-ulimit.conf'
