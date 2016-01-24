#
# Cookbook Name:: cyly-aem
# Recipe:: author
#
# Copyright (C) 2015 DigitalLync, Inc.
#
# All rights reserved - Do Not Redistribute
#
# a recipe for the AEM author instance
#
include_recipe 'cyly-aem::_common_setup'
include_recipe 'java'

# knock iptables out for now at least
include_recipe 'iptables::disabled'

base_dir = node[:aem][:author][:base_dir]

# set the jar_opts based on the cluster
unless Chef::Config['solo']
  env_type = node.chef_environment == 'prod' ? 'prod' : 'non-prod'
  # derive this from the node name (2nd and 4th elements)
  node_type = node.name.split('-').values_at(1,3).join('-')
  
  node.default['aem']['author']['jar_opts'] = [ "-r #{node.chef_environment} #{node['aem']['cluster_name']} #{node['fqdn']} nosamplecontent author #{env_type} #{node_type}" ]
end

# Update owner recursively for base folders
# This is because these folders are created by IT Infra beforehand
# and will be owned by "root" by default. This needs to be "crx" before proceeding

if File.exists?(base_dir)
  dirs = ['', '/dumps', '/logs', '/repository']
  dirs.each do |path|
    directory "#{base_dir}#{path}" do
      owner 'crx'
      group 'crx'
      mode '0755'
    end
  end
end

# unpack the jar
unless node[:aem][:use_yum]
  aem_jar_installer "author" do
    download_url node[:aem][:download_url]
    default_context node[:aem][:author][:default_context]
    port node[:aem][:author][:port]
    action :install
  end
end

# set wily jvm options
#if File.exists?('/opt/wily/Agent.jar')
# node.default[:aem][:author][:jvm_opts].merge!(
#   '-javaagent:/opt/wily/Agent.jar' => true,
#    '-Dcom.wily.introscope.agentProfile=/opt/wily/core/config/IntroscopeAgent.profile' => true
#  )
#else
#  Chef::Log.warn('Agent.jar not found at /opt/wily/Agent.jar')
#end
# set newrelic jvm options
#W-2829703 - Add-NewRelicToJVM - https://gus.my.salesforce.com/apex/adm_userstorydetail?id=a07B0000001lFqQIAU&cyly.override=1
#if File.exists?('/opt/newrelic/newrelic.jar')
#  node.default[:aem][:author][:jvm_opts].merge!(
#    '-javaagent:/opt/newrelic/newrelic.jar' => true,
#    "-Dnewrelic.environment=#{node.chef_environment}" => true
#  )
#else
#  Chef::Log.warn('Agent.jar not found at /opt/newrelic/newrelic.jar')
#end

# check to see if properties file needs to be updated before template executes
# if the prop file exists (won't the first time) AND the prop file does NOT have wily 
# template should update and service should restart
# hardcode regex for now, if more are added this needs to be updated
# TODO - loop over regex attributes
unless File.exists?("#{base_dir}/conf/sling.properties") && open("#{base_dir}/conf/sling.properties") { |f| f.grep(/^sling\.bootdelegation\.simple\=com\.wily\.\*$/).any? }
  Chef::Log.info('updating sling properties')
  template "#{base_dir}/conf/sling.properties" do
    owner "crx"
    group "crx"
    mode "0644"
    source "sling_properties.erb"
    variables(
        :sling_properties => node['aem']['sling_properties'],
        :prop_regexes => node['aem']['prop_regexes']
      )
    notifies :restart, "service[aem-author]"
  end
end

template "#{base_dir}/conf/jmxremote.password" do
    owner "crx"
    group "crx"
    mode "0400"
    source "jmxremote.password.erb"
end

include_recipe 'aem::author'
#include_recipe 'cyly-aem::_archive_setup'

node['aem']['author']['jcr_nodes'].each do |jcr_node|
  aem_jcr_node jcr_node['name'] do
    path jcr_node['path']
    user node['aem']['author']['admin_user']
    password node['aem']['author']['admin_password']
    contents jcr_node['contents']
    type 'file'
    host 'localhost'
    port node['aem']['author']['port']
  end
end

template "/sbin/aem_replication" do
  owner "root"
  group "root"
  mode "0744"
  source "aem_replication.erb"
  variables(
    :author_user => node[:aem][:author][:admin_user],
    :author_password => node[:aem][:author][:admin_password],
    :publish_user => node[:aem][:publish][:admin_user],
    :publish_password => node[:aem][:publish][:admin_password]
  )
end

template "/sbin/package_preserver" do
  owner "root"
  group "root"
  mode "0744"
  source "package_preserver.erb"
  variables(
    :admin_user => node[:aem][:author][:admin_user],
    :admin_password => node[:aem][:author][:admin_password],
    :port => node[:aem][:author][:port]
  )
end

