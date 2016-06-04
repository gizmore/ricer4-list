require "ricer4"
require "kaminari"
Kaminari::Hooks.init
module Ricer4
  module Plugins
    module List
      
      add_ricer_plugin_module(File.dirname(__FILE__)+'/ricer4/list')
      
    end
  end
end
