#
# Cookbook Name:: cyly-aem
# Recipe:: _dispatcher_common
#
# Copyright (C) 2015 DigitalLync, Inc.
#
# All rights reserved - Do Not Redistribute
#
# We're doing one-to-one dispatchers, so find our partner
# Using the node name to derive the partner's node name
unless Chef::Config['solo']
  name = node.name
  case name
  when /web-wca-dispatcher/
    type = replace_string = 'author'
    port = node['aem']['author']['port']
  when /web-wc(s|p)-dispatcher/
    type = 'publish'
    replace_string = 'publisher'
    port = node['aem']['publish']['port']
  else
    raise "#{name} does not match any known dispatcher type (author or publisher)"
  end
  aem_name = name.sub('dispatcher', replace_string)
  Chef::Log.info("Searching for node named #{aem_name}")
  render = search(:node, %Q(name:"#{aem_name}" AND role:cyly-#{type})).first
  if render
    Chef::Log.info("Found node #{render['name']} with IP #{render['ipaddress']}")
    node.default['aem']['dispatcher'][type]['renders'] = [{
      :name => aem_name,
      :hostname => render['ipaddress'],
      :port => port,
      :timeout => '0'
    }]
    # I'm using a normal here because of some weirdness with the attribute 
    # merge that I haven't figured out yet.  This will add the render to 
    # allowed cache-flush clients the next chef run after it finds it.  This
    # is not awesome, but it works ok for now.
    node.normal['aem']['dispatcher']['allowed_clients']['0003'] = 
      { :glob => render[:ipaddress], :type => 'allow' }
  else
    Chef::Log.warn("Server #{aem_name} not found.  This is expected if that server has not yet been configured with Chef.  This dispatcher will not be able to serve content until then.")
  end
end

#include_recipe 'newrelic'
#newrelic_server_monitor 'Install' do
#  license node['newrelic']['license']
#end
#
#include_recipe 'apache-newrelic-plugin'
#service "apache-newrelic-monitor" do
#  action :start
#end
