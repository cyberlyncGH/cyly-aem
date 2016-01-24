#
# Cookbook Name:: cyly-aem
# Recipe:: author_dispatcher
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
include_recipe 'cyly-aem::_dispatcher_common'
package 'unzip'

filters = node['aem']['dispatcher']['author']['filter_rules']
cache_root = "#{node['aem']['dispatcher']['cache_root']}/author"
cache_rules = node['aem']['dispatcher']['author']['cache_rules']

# create dispatcher.conf with author specific pass_error
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
      :pass_error => node[:aem][:dispatcher][:author][:pass_error]
    })
  end
end

# properly set the owner and mode of the folders leading up to the author 
# not pretty but recommended in the chef-docs:
# https://docs.chef.io/resource_directory.html#recursive-directories

%w[/opt/communique/ /opt/communique/dispatcher /opt/communique/dispatcher/cache].each do |path|
  directory path do
    owner 'apache'
    group 'apache'
    mode '0755'
  end
end

aem_farm '10author' do
  renders node['aem']['dispatcher']['author']['renders']
  virtual_hosts node['aem']['dispatcher']['author']['virtual_hosts']
  cache_root cache_root
  filter_rules filters
  cache_rules cache_rules
  enable_session_mgmt true
  dynamic_cluster node['aem']['dispatcher']['dynamic_cluster']
  cluster_name node['aem']['cluster_name']
  cluster_role node['aem']['author']['cluster_role']
  cluster_type 'author'
  action :add
end

aem_website '10author_dispatcher' do
  server_name node['aem']['dispatcher']['author']['server_name']
  server_aliases node['aem']['dispatcher']['author']['server_aliases']
  rewrites node['aem']['dispatcher']['author']['rewrites']
  cache_root cache_root
  template_cookbook 'cyly-aem'
  template_name 'cyly_aem_dispatcher.conf.erb'
  action :add
end
