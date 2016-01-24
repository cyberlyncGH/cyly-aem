#
# Cookbook Name:: cyly-aem
# Recipe:: _common_setup
#
# Copyright 2015, DigitalLync, Inc.
#
# All rights reserved - Do Not Redistribute

#include_recipe 'cyly-jenkins::user'

deploy_user = node['aem']['deploy']['user']

user deploy_user do
  comment "Deployment user"
  system true
  shell "/bin/bash"
  home "/home/#{deploy_user}"
  supports :manage_home => true 
end

directory "/home/#{deploy_user}/.ssh" do
  owner deploy_user
  group deploy_user
  mode "0700"
end

ssh_authorize_key deploy_user do
  key node['aem']['deploy']['ssh_key']
  user deploy_user
end

# ensure that /etc/sudoers includes /etc/sudoers.d
unless Chef::Config['solo']
  fe = Chef::Util::FileEdit.new("/etc/sudoers")
  fe.insert_line_if_no_match(/#includedir \/etc\/sudoers\.d/,'#includedir /etc/sudoers.d')
  fe.write_file
end

sudo 'deploy_aem' do
  user deploy_user
  runas 'root'
  defaults ['!requiretty']
  nopasswd true
  commands [
    '/sbin/service aem-author status',
    '/sbin/service aem-author stop',
    '/sbin/service aem-author start',
    '/sbin/service aem-publish status',
    '/sbin/service aem-publish stop',
    '/sbin/service aem-publish start',
    '/sbin/service chef-client status',
    '/sbin/service chef-client stop',
    '/sbin/service chef-client start',
    '/sbin/aem_replication on',
    '/sbin/aem_replication off',
    '/usr/bin/chef-client',
    "/sbin/package_preserver download #{node['aem']['users_groups_package']}",
    "/sbin/package_preserver upload #{node['aem']['users_groups_package']}",
  ]
end

sudo 'deploy_crx' do
  user deploy_user
  runas node['aem']['aem_options']['RUNAS_USER']
  defaults ['!requiretty']
  nopasswd true
  commands [ 'ALL' ]
end

# If running chef-client, search for the dispatcher for the flush agent
# Dispatchers are 1-to-1 with AEM nodes

if node[:aem][:use_yum] then
  package 'aem' do
    version node[:aem][:version]
    action :install
  end
else
  user "crx" do
    comment "crx/aem role user"
    system true
    shell "/bin/bash"
    home "/home/crx"
    supports :manage_home => true
    action :create
  end
end

# set system ulimit
include_recipe 'sysctl::apply'
# set the crx user ulimit
include_recipe 'ulimit::default'

#include_recipe 'newrelic'
#newrelic_server_monitor 'Install' do
#  license node['newrelic']['license']
#end

