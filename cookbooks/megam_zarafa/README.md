
[![Build Status](https://travis-ci.org/computerlyrik/chef-zarafa.png)](https://travis-ci.org/computerlyrik/chef-zarafa)
# Description

Code Repo: http://github.com/computerlyrik/chef-zarafa

Motivated by freeing mobile devices:

Setup Zarafa to 
- sync your Android/i/Windows Phone (ActiveSync)
- have eMail push
- receive and send emails via imap
- Webinterface to manage all

**For more see http://www.zarafa.com/content/mobility**

# Requirements
Cookbooks
```
mysql and database

modified openldap_cookbook reachable at ...TODO
```

# Attributes
Set up a catchall user with
```ruby
node['zarafa']['catchall'] = "mail@mydomain.com"
```

# Usage
run recipe

# Contact
see metadata.rb

# TODO
- fix vmail (mailbox transport or virtual boxes)
- test mysql installation
- test auto-installation by packages
- separate simple users via virtual and email2email config
