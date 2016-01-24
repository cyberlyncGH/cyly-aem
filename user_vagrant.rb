# rename this file .user_vagrant.rb and add your own configs
chef.log_level = 'debug'
local_json = {
  aem: {
    author: {
    }
  }
}
chef.json.merge!(local_json)
