############################################
# Cookbook Name:: cyly-aem                 #
# Attributes:: defaults                    #
# Copyright (C) 2015 DigitalLync, Inc.     #
# All rights reserved - Do Not Redistribute#
############################################

# attributes for author and publish
default['aem']['version'] = '6.1.0'
default['aem']['download_url'] = 'file:///vagrant/author-4502.jar'
default['aem']['license_url'] = 'file:///vagrant/license.properties'

default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true

# attributes for setting the ulimit of the system and crx to desired values
default['ulimit']['users']['crx']['filehandle_soft_limit'] = 63536
default['ulimit']['users']['crx']['filehandle_hard_limit'] = 63536
default['sysctl']['params']['fs']['file-max'] = 65536

# may only apply to the older version of the iptables cookbook
default['iptables']['install_rules'] = false

#default['aem']['jcr_nodes'] = []
#default['aem']['archive']['user'] = 'archive'
#default['aem']['archive']['server_role'] = 'sfdc-archive'
#default['aem']['archive']['author_source_server'] = 'PLEASE_SET_THIS'
#default['aem']['archive']['publish_source_server'] = 'PLEASE_SET_THIS'
#default['aem']['archive']['sync_times'] = '8 * * * *'
#default['aem']['archive']['content_packages_path'] = '/data/aem-archive/content-packages'
#default['aem']['archive']['content_packages_definition_path'] = '/home/archive/content-packages-definition'

default['aem']['deploy']['user'] = 'jenkins'

default['aem']['aem_options']['JAVA_HOME'] = '/usr/java/default'
default['aem']['aem_options']['RUNAS_USER'] = 'crx'
default['aem']['aem_options']['CQ_HEAP_MIN'] = '12288'
default['aem']['aem_options']['CQ_HEAP_MAX'] = '12288'
default['aem']['aem_options']['CQ_PERMGEN'] = '1024'

default['aem']['sling_properties'] = [ 'sling.bootdelegation.simple=com.wily.*' ]
default['aem']['prop_regexes'] = [ '^sling\.bootdelegation\.simple\=com\.wily\.\*$' ]

# used in the aem_jar_installer to allow for a more fine grain check to determine if an unpack is necessary or not
default[:aem][:unpack_jar_dir] = "crx-quickstart/bin"

# attributes for author
default['aem']['author']['jcr_nodes'] = []
default['aem']['author']['admin_user'] = 'admin'
default['aem']['author']['admin_password'] = 'admin'
default['aem']['author']['new_admin_password'] = 'admin'



# attirbutes for publish
default['aem']['publish']['jcr_nodes'] = []
default['aem']['publish']['admin_user'] = 'admin'
default['aem']['publish']['admin_password'] = 'admin'
default['aem']['publish']['new_admin_password'] = 'admin'

default['aem']['author']['jvm_opts'] = {
  "-Xloggc:#{node[:aem][:author][:base_dir]}/logs/gc.log" => true,
  '-verbose:gc' => true,
  '-XX:+PrintGCDetails' => true,
  '-XX:+PrintGCTimeStamps' => true,
  '-XX:+PrintGCDateStamps' => true,
  '-XX:+UseGCLogFileRotation' => true,
  '-XX:NumberOfGCLogFiles=5' => true,
  '-XX:GCLogFileSize=512K' => true,
  '-XX:+HeapDumpOnOutOfMemoryError' => true,
  "-XX:HeapDumpPath=#{node[:aem][:author][:base_dir]}/dumps" => true,

  # Jackrabbit params from Yugi (Adobe)
  '-Djackrabbit.maxQueuedEvents=1000000' => true,

  # JMX
  '-Dcom.sun.management.jmxremote=true' => true,
  '-Dcom.sun.management.jmxremote.port=9999' => true,
  '-Dcom.sun.management.jmxremote.rmi.port=9999' => true,
  '-Dcom.sun.management.jmxremote.local.only=false' => true,
  '-Dcom.sun.management.jmxremote.authenticate=true' => true,
  '-Dcom.sun.management.jmxremote.ssl=false' => true,
  "-Dcom.sun.management.jmxremote.password.file=#{node[:aem][:author][:base_dir]}/conf/jmxremote.password" => true
}

# attributes for publish
default['aem']['publish']['jcr_nodes'] = []
default['aem']['publish']['jvm_opts'] = {
  "-Xloggc:#{node[:aem][:publish][:base_dir]}/logs/gc.log" => true,
  '-verbose:gc' => true,
  '-XX:+PrintGCDetails' => true,
  '-XX:+PrintGCTimeStamps' => true,
  '-XX:+PrintGCDateStamps' => true,
  '-XX:+UseGCLogFileRotation' => true,
  '-XX:NumberOfGCLogFiles=5' => true,
  '-XX:GCLogFileSize=512K' => true,
  '-XX:+HeapDumpOnOutOfMemoryError' => true,
  # TODO or /tmp?
  "-XX:HeapDumpPath=#{node[:aem][:publish][:base_dir]}/logs" => true,

  # Jackrabbit params from Yugi (Adobe)
  '-Djackrabbit.maxQueuedEvents=1000000' => true
}

default['aem']['publish']['cluster_role'] = 'cyly-publish'
default['aem']['cache_hosts'] = [{ 
  :ipaddress => 'localhost',
  :port => '80',
  :user => 'admin',
  :password => 'admin'
}]

# dispatcher attributes
default['aem']['dispatcher']['version'] = '4.1.9'
default['aem']['dispatcher']['dispatcher_file_cookbook'] = 'cyly-aem'
default['aem']['dispatcher']['dynamic_cluster'] = false
default['aem']['dispatcher']['use_processed_url'] = '1'

default['aem']['dispatcher']['author']['server_name'] = node[:fqdn]
default['aem']['dispatcher']['publish']['server_name'] = node[:fqdn]

#W-2734515 - create flush agents for author
default['aem']['dispatcher']['author']['cluster_role'] = 'cyly-author-dispatcher'

# W-2718662 - Default behavior is to only allow *.html flushes.
# We need to allow everything (js, css, etc)
default['aem']['dispatcher']['invalidation_rules'] = {
    '0000' => { :glob => "*", :type => "allow" }
}

# W-2736510 - P1 {SF LIVE}  Request Apache Max Clients and Server Limit  Change From Default to 1024
default['apache']['prefork']['startservers']        = 5
default['apache']['prefork']['minspareservers']     = 5
default['apache']['prefork']['maxspareservers']     = 10
default['apache']['prefork']['serverlimit']         = 2260
default['apache']['prefork']['maxrequestworkers']   = 2260
default['apache']['prefork']['maxconnectionsperchild'] = 10_000

default['aem']['dispatcher']['author']['pass_error'] = '0'
default['aem']['dispatcher']['publish']['pass_error'] = '1'

default['aem']['dispatcher']['publish']['renders'] = [{:name => 'publish_rend',
  :hostname => '127.0.0.1', :port => '4503', :timeout => '0'}]


default['aem']['dispatcher']['publish']['cache_root'] = '/opt/communique/dispatcher/cache'

default['aem']['dispatcher']['author']['renders'] = [{:name => 'author_rend',
  :hostname => '127.0.0.1', :port => '4502', :timeout => '0'}]
default['aem']['dispatcher']['author']['rewrites'] = []

# set defaults for dispatcher author
default['aem']['dispatcher']['author']['virtual_hosts'] = ["*"]
default['aem']['dispatcher']['author']['server_aliases'] = []


# cache options for dispatcher
default['aem']['dispatcher']['cache_opts'] = [
  '/statfileslevel "0"',
  '/serveStaleOnError "1"',
  '/allowAuthorized "0"'
]

# allowed invalidation clients
default['aem']['dispatcher']['allowed_clients']['0001'] =
  { :glob => "*.*.*.*", :type => "deny" }
# this one will be replaced with the renderer(s) in the recipe
# if dynamic_cluster is true
default['aem']['dispatcher']['allowed_clients']['0002'] =
  { :glob => "127.0.0.1", :type => "allow" }

#ignoreUrlParams
default['aem']['dispatcher']['ignore_url_params']['0001'] = {:glob => "*",        :type => "deny"}
default['aem']['dispatcher']['ignore_url_params']['0002'] = {:glob => "d",        :type => "allow"}
default['aem']['dispatcher']['ignore_url_params']['0003'] = {:glob => "nc",       :type => "allow"}
default['aem']['dispatcher']['ignore_url_params']['0004'] = {:glob => "internal", :type => "allow"}
default['aem']['dispatcher']['ignore_url_params']['0005'] = {:glob => "qajson",   :type => "allow"}


# set defaults for dispatcher publish
default['aem']['dispatcher']['publish']['virtual_hosts'] = ["*"]
default['aem']['dispatcher']['publish']['server_aliases'] = []

# deny everything and allow specific entries
default['aem']['dispatcher']['publisher_filter_rules']['0001'] = '/type "deny" /glob "*"'

# Enable normal HTML content grabbing
default['aem']['dispatcher']['publisher_filter_rules']['0023'] = '/type "allow" /method "GET" /url "/content/blogs*.html"'
default['aem']['dispatcher']['publisher_filter_rules']['0024'] = '/type "allow" /method "GET" /url "/content/www*.html"'
default['aem']['dispatcher']['publisher_filter_rules']['0025'] = '/type "allow" /method "GET" /url "/content/campaigns*.html"'
# allow salesforce live content paths
default['aem']['dispatcher']['publisher_filter_rules']['0026'] = '/type "allow" /method "GET" /url "/content/live/*/home*.html"'
# allow marketing cloud guided tour content paths
default['aem']['dispatcher']['publisher_filter_rules']['0027'] = '/type "allow" /method "GET" /url "/content/marketing-cloud*.html"'


# enable specific mime types in non-public content directories
default['aem']['dispatcher']['publisher_filter_rules']['0141'] = '/type "allow" /method "GET" /url "*.css"'  # enable css
default['aem']['dispatcher']['publisher_filter_rules']['0142'] = '/type "allow" /method "GET" /url "*.gif"'  # enable gifs
default['aem']['dispatcher']['publisher_filter_rules']['0143'] = '/type "allow" /method "GET" /url "*.ico"'  # enable icos
default['aem']['dispatcher']['publisher_filter_rules']['0144'] = '/type "allow" /method "GET" /url "*.js"'   # enable javascript
default['aem']['dispatcher']['publisher_filter_rules']['0145'] = '/type "allow" /method "GET" /url "*.png"'  # enable png
default['aem']['dispatcher']['publisher_filter_rules']['0146'] = '/type "allow" /method "GET" /url "*.swf"'  # enable flash
default['aem']['dispatcher']['publisher_filter_rules']['0147'] = '/type "allow" /method "GET" /url "*.svg"'  # enable svg
default['aem']['dispatcher']['publisher_filter_rules']['0148'] = '/type "allow" /method "GET" /url "*.woff"' # enable woff
default['aem']['dispatcher']['publisher_filter_rules']['0149'] = '/type "allow" /method "GET" /url "*.ttf"'  # enable ttf
default['aem']['dispatcher']['publisher_filter_rules']['0150'] = '/type "allow" /method "GET" /url "*.eot"'  # enable eot
default['aem']['dispatcher']['publisher_filter_rules']['0151'] = '/type "allow" /method "GET" /url "*.jpg"'  # enable jpg
default['aem']['dispatcher']['publisher_filter_rules']['0152'] = '/type "allow" /method "GET" /url "*.woff2"' # enable woff2

# deny all selectors (anything with 2 or more ".", basically)
default['aem']['dispatcher']['publisher_filter_rules']['0289'] = '/type "deny" /url "*.*.*"'


# Deny null-byte (security issue)
default['aem']['dispatcher']['publisher_filter_rules']['0290'] = '/type "deny" /url "*\x00"'

# Deny specific querystring
default['aem']['dispatcher']['publisher_filter_rules']['0291'] = '/type "deny" /query "debug*"'

# Allow certain selectors
default['aem']['dispatcher']['publisher_filter_rules']['0300'] = '/type "allow" /method "GET" /url "*.min.css"'
default['aem']['dispatcher']['publisher_filter_rules']['0301'] = '/type "allow" /method "GET" /url "*.min.js"'

# allow selectors for reading segments
default['aem']['dispatcher']['publisher_filter_rules']['0302'] = '/type "allow" /method "GET" /url "/etc/segmentation.segment.js"'
default['aem']['dispatcher']['publisher_filter_rules']['0304'] = '/type "allow" /method "GET" /url "/etc/segmentation/*.segment.js"'

# allow selectors for acs common versioned clientlibs with hash
default['aem']['dispatcher']['publisher_filter_rules']['0305'] = '/type "allow" /method "GET" /url "*.min.*.css"'
default['aem']['dispatcher']['publisher_filter_rules']['0306'] = '/type "allow" /method "GET" /url "*.min.*.js"'

# Allow renditions for legacy blog
default['aem']['dispatcher']['publisher_filter_rules']['0310'] = '/type "allow" /method "GET" /url "/content/dam/blogs/legacy/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*.jpg/_jcr_content/renditions/*.jpg"'
default['aem']['dispatcher']['publisher_filter_rules']['0311'] = '/type "allow" /method "GET" /url "/etc/clientcontext/cyly/content/jcr:content/stores.init.js"'

# Allow healthcheck
default['aem']['dispatcher']['publisher_filter_rules']['0400'] = '/type "allow" /method "HEAD" /url "/blog/"'

# Disable ALL bad request that can be spoofed using a suffix / deny content grabbing
default['aem']['dispatcher']['publisher_filter_rules']['0500'] = '/type "deny" /url "*.json*"'
default['aem']['dispatcher']['publisher_filter_rules']['0501'] = '/type "deny" /url "*.xml*"'
default['aem']['dispatcher']['publisher_filter_rules']['0502'] = '/type "deny" /url "*.zip*"'

default['aem']['dispatcher']['author']['filter_rules']['0001'] = '/type "allow" /glob "*"'
default['aem']['dispatcher']['author']['filter_rules']['0010'] = '/type "deny" /glob "* /admin/*"'
default['aem']['dispatcher']['author']['filter_rules']['0011'] = '/type "deny" /glob "* /admin *"'
default['aem']['dispatcher']['author']['filter_rules']['0012'] = '/type "deny" /glob "* /system/*"'
default['aem']['dispatcher']['author']['filter_rules']['0013'] = '/type "deny" /glob "* /_jcr_system/*"'
default['aem']['dispatcher']['author']['filter_rules']['0014'] = '/type "deny" /glob "* /jcr:system/*"'
default['aem']['dispatcher']['author']['filter_rules']['0015'] = '/type "deny" /glob "* /crx/*"'
default['aem']['dispatcher']['author']['filter_rules']['0016'] = '/type "deny" /glob "* /crx *"'
default['aem']['dispatcher']['author']['filter_rules']['0017'] = '/type "deny" /glob "* /bin/crxde*"'
default['aem']['dispatcher']['author']['filter_rules']['0052'] = '/type "allow" /glob "GET /system/sling/logout.html*"'

default['aem']['dispatcher']['author']['cache_rules'] =  {
  "0000" => { :glob => "*", :type => "deny" },
  "0001" => { :glob => "/libs/*", :type => "allow" },
  "0002" => { :glob => "/libs/*.html", :type => "deny" },
  "0003" => { :glob => "/apps/*", :type => "allow" },
  "0004" => { :glob => "/apps/*.html", :type => "deny" },
  "0020" => { :glob => "/etc/clientlibs/*", :type => "allow" },
  "0030" => { :glob => "/etc/designs/*", :type => "allow" }
}



# setting statitics to empty array because it has a value in the base cookbook
default["aem"]["dispatcher"]["statistics"] = []


#cyly client headers
default["aem"]["dispatcher"]["client_headers"] =[
  "referer",
  "user-agent",
  "authorization",
  "from",
  "content-type",
  "content-length",
  "accept-charset",
  "accept-encoding",
  "accept-language",
  "accept",
  "host",
  "if-match",
  "if-none-match",
  "if-range",
  "if-unmodified-since",
  "max-forwards",
  "proxy-authorization",
  "proxy-connection",
  "range",
  "cookie",
  "cq-action",
  "cq-handle",
  "handle",
  "action",
  "cqstats",
  "depth",
  "translate",
  "expires",
  "date",
  "dav",
  "ms-author-via",
  "if",
  "lock-token",
  "x-expected-entity-length",
  "destination",
  "X-Salesforce-SIP",
  "X-FORWARDED-FOR",
  "CSRF-Token"]

  #cyly client headers extra for publish only
default["aem"]["dispatcher"]['publish']["client_headers"] =[
   "X-FORWARDED-PROTO",
   "X-Forwarded-SSL"]

#deny clickjacking
default['aem']['dispatcher']['header'] = ['Header always append X-Frame-Options SAMEORIGIN']

# the US locale must separated in order for styled 404 pages to load properly
# refer to templates/default/cyly_aem_dispatcher.conf.erb to see the implementation
default[:aem][:dispatcher][:expire_dirs] = {
  :none_location_match =>[{
    :path => "/*", 
    :rules => [
      "ErrorDocument 403 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 404 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 500 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 503 /content/live/en_us/home/errors/404.html"
  ]}],
  :location_match => [
    {
    :path => "/content/live/en_us/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 500 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 403 /content/live/en_us/home/errors/404.html",
      "ErrorDocument 503 /content/live/en_us/home/errors/404.html"
    ]},
    {
    :path => "/content/live/ja_jp/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/ja_jp/home/errors/404.html",
      "ErrorDocument 500 /content/live/ja_jp/home/errors/404.html",
      "ErrorDocument 403 /content/live/ja_jp/home/errors/404.html",
      "ErrorDocument 503 /content/live/ja_jp/home/errors/404.html"
    ]},
    {
    :path => "/content/live/nl_nl/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/nl_nl/home/errors/404.html",
      "ErrorDocument 500 /content/live/nl_nl/home/errors/404.html",
      "ErrorDocument 403 /content/live/nl_nl/home/errors/404.html",
      "ErrorDocument 503 /content/live/nl_nl/home/errors/404.html"
    ]},
    {
    :path => "/content/live/de_de/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/de_de/home/errors/404.html",
      "ErrorDocument 500 /content/live/de_de/home/errors/404.html",
      "ErrorDocument 403 /content/live/de_de/home/errors/404.html",
      "ErrorDocument 503 /content/live/de_de/home/errors/404.html"
    ]},
    {
    :path => "/content/live/en_au/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/en_au/home/errors/404.html",
      "ErrorDocument 500 /content/live/en_au/home/errors/404.html",
      "ErrorDocument 403 /content/live/en_au/home/errors/404.html",
      "ErrorDocument 503 /content/live/en_au/home/errors/404.html"
    ]},
    {
    :path => "/content/live/en_gb/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/en_gb/home/errors/404.html",
      "ErrorDocument 500 /content/live/en_gb/home/errors/404.html",
      "ErrorDocument 403 /content/live/en_gb/home/errors/404.html",
      "ErrorDocument 503 /content/live/en_gb/home/errors/404.html"
    ]},
    {
    :path => "/content/live/fr_fr/.*", 
    :rules => [
      "ErrorDocument 404 /content/live/fr_fr/home/errors/404.html",
      "ErrorDocument 500 /content/live/fr_fr/home/errors/404.html",
      "ErrorDocument 403 /content/live/fr_fr/home/errors/404.html",
      "ErrorDocument 503 /content/live/fr_fr/home/errors/404.html"
    ]},
    {:path => "/fr/.*", :rules => ["ErrorDocument 404 /content/blogs/fr/fr/errors/404.html"]},
    {:path => "/de/.*", :rules => ["ErrorDocument 404 /content/blogs/de/de/errors/404.html"]},
    {:path => "/uk/.*", :rules => ["ErrorDocument 404 /content/blogs/gb/en/errors/404.html"]},
    {:path => "/ca/.*", :rules => ["ErrorDocument 404 /content/blogs/ca/en/errors/404.html"]},
    {:path => "/au/.*", :rules => ["ErrorDocument 404 /content/blogs/au/en/errors/404.html"]},
    {:path => "/jp/.*", :rules => ["ErrorDocument 404 /content/blogs/jp/ja/errors/404.html"]},
    {:path => "/nl/.*", :rules => ["ErrorDocument 404 /content/blogs/nl/nl/errors/404.html"]},
    {:path => "/br/.*", :rules => ["ErrorDocument 404 /content/blogs/br/pt/errors/404.html"]},
    {:path => "/content/marketing-cloud/en_us/.*",
        :rules => ["ErrorDocument 404 /content/marketing-cloud/en_us/errors/404.html"
    ]}
  ]
}

# attributes for jenkins
default['jenkins']['node']['user'] = 'jenkins'

# attributes for deploy
default['aem']['deploy']['ssh_key'] = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCeF2VmBvx0Vc8HmAo9ivKlLuijsDq2XeCHfVNalkWwXh2gAn8rFrCyLl/Mp/zn9MkhpA41c+BwawVPfcdrvmSaS5B7ShIgz/tuOTbUL4aleqS3BlSSO6LsHK3Hwxm0IqNc2y1efCscdNWLbdwvtOnKloglnnnoMVUlxoRFSyvAuxAUJ810JJrD8rj3OvImeJuStMfECKgReoHmHwdRH0mLjrpudZdlg6JUSuI/PXqM98VUIhHJMjrWIsy1D71BvR66EpFg1j/EC8dP6JCRhR6BKwGXKbpoeHLjU0LyA1PETHTymP4URyo0SqTR/GLiSVrBoqJN4sCkYLgrPZjFg0YJ'

# attirbutes for apache
default['apache']['libexecdir'] = '/usr/lib64/httpd/modules'
default['apache']['serversignature'] = 'Off'
default['apache']['servertokens'] = 'Prod'
default['apache']['traceenable'] = 'Off'

#overrides
override['aem']['commands']['replicators']['publish']['add'] = 'curl -u <%=local_user%>:<%=local_password%> -X POST http://localhost:<%=local_port%>/etc/replication/agents.author/<%=aem_instance%><%=instance%>/_jcr_content -d jcr:title="<%=type%> Agent <%=h[:name]%>" -d transportUri=http://<%=h[:ipaddress]%>:<%=h[:port]%>/bin/receive?sling:authRequestLogin=1 -d enabled=true -d transportUser=<%=h[:user]%> -d transportPassword=<%=h[:password]%> -d cq:template="/libs/cq/replication/templates/agent" -d retryDelay=60000 -d logLevel=info -d serializationType=durbo -d jcr:description="<%=type%> Agent <%=instance%>" -d sling:resourceType="cq/replication/components/agent"'

# Configure attributes for Apache monitor
#default['apache_newrelic_plugin']['agents'] = [{
# :name => node['hostname'],
# :host => 'localhost',
#}]
