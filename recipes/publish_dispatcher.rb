#
# Cookbook Name:: cyly-aem
# Recipe:: publish_dispatcher
#
# Copyright (C) 2015 DigitalLync, Inc.
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'aem::dispatcher'

# knock iptables out for now at least
include_recipe 'iptables::disabled'

include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_proxy_balancer'
include_recipe 'apache2::mod_expires'

include_recipe 'apache2::mpm_prefork'
# work around to comment out the mpm_prefork.load file since the mpm_prefork module comes with apache 2.2 pre-installed
# https://github.com/svanzoest-cookbooks/apache2/issues/241
r = resources(:file => "#{node['apache']['dir']}/mods-available/mpm_prefork.load")
r.content "# No LoadModule declaration required as mpm_prefork is compiled in in apache 2.2\n"

include_recipe 'cyly-aem::_dispatcher_common'
package 'unzip'

# create dispatcher.conf with publish specific pass_error
%w(/mods-available).each do |httpd_dir|
  conf_path = node['apache']['dir'] + httpd_dir + '/dispatcher.conf'

  template conf_path do 
    source 'dispatcher.conf.erb'
    notifies :restart, 'service[apache2]', :delayed
    variables({
      :fqdn => node[:fqdn],
      :conf_file => node[:aem][:dispatcher][:conf_file],
      :log_file  => node[:aem][:dispatcher][:log_file],
      :log_level => node[:aem][:dispatcher][:log_level],
      :no_server_header => node[:aem][:dispatcher][:no_server_header],
      :decline_root => node[:aem][:dispatcher][:decline_root],
      :use_processed_url => node[:aem][:dispatcher][:use_processed_url],
      :pass_error => node[:aem][:dispatcher][:publish][:pass_error]
    })
  end
end

publish_client_headers = []

node['aem']['dispatcher']['client_headers'].each do |header|
  publish_client_headers << header
end

node['aem']['dispatcher']['publish']['client_headers'].each do |header|
  publish_client_headers << header
end

Chef::Log.info(publish_client_headers)

aem_farm '00publish' do
  cache_root node['aem']['dispatcher']['publish']['cache_root']
  virtual_hosts node['aem']['dispatcher']['publish']['virtual_hosts']
  renders node['aem']['dispatcher']['publish']['renders']
  filter_rules node['aem']['dispatcher']['publisher_filter_rules']
  dynamic_cluster node['aem']['dispatcher']['dynamic_cluster']
  client_headers publish_client_headers
  cluster_name node['aem']['cluster_name']
  cluster_role node['aem']['publish']['cluster_role']
  cluster_type 'publish'
  action :add
end

# properly set the owner and mode of the folders leading up to /opt/communique/dispatcher/cache 
# not pretty but recommended in the chef-docs:
# https://docs.chef.io/resource_directory.html#recursive-directories

%w[/opt/communique/ /opt/communique/dispatcher /opt/communique/dispatcher].each do |path|
  directory path do
    owner 'apache'
    group 'apache'
    mode '0755'
  end
end

aem_website '00publish_dispatcher' do
  server_name node['aem']['dispatcher']['publish']['server_name']
  cache_root node['aem']['dispatcher']['publish']['cache_root']
  server_aliases node['aem']['dispatcher']['publish']['server_aliases']
  rewrites node['aem']['dispatcher']['publish']['rewrites']
  template_cookbook 'cyly-aem'
  template_name 'cyly_aem_dispatcher.conf.erb'
  action :add
end
