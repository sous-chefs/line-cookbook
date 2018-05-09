name             'line'
maintainer       'Sous Chefs'
maintainer_email 'help@sous-chefs.org'
license          'Apache-2.0'
description      'Provides line editing resources for use by recipes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.0'
source_url       'https://github.com/sous-chefs/line-cookbook'
issues_url       'https://github.com/sous-chefs/line-cookbook/issues'
chef_version     '>= 12.5' if respond_to?(:chef_version)

%w(debian ubuntu centos redhat scientific oracle amazon windows).each do |os|
  supports os
end
