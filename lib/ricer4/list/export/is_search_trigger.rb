require "active_record"
require "dusen"
require 'edge_rider'
require 'dusen/active_record/base_ext'
require 'dusen/active_record/search_text'

module Ricer4::Extend::IsSearchTrigger

  SEARCH_TRIGGER_OPTIONS ||= {
    :for => nil,
    per_page: 5,
    order: 'created_at',
    search_pattern: '<search_term>',
    pagination_pattern: '<page>', # falsy to disable
  }
  
  
  def is_search_trigger(trigger_name, options={})
    class_eval do |klass|

      ActiveRecord::Magic::Options.merge(options, SEARCH_TRIGGER_OPTIONS)
      
      has_list_functions(options)
      
      ##############
      ### Plugin ###
      ##############
      trigger_is trigger_name

      ###
      # Paginated, some of them with search
      klass.has_usage "#{options[:search_pattern]} <page>", function: :execute_search if options[:pagination_pattern]
      klass.has_usage "#{options[:search_pattern]}", function: :execute_search
      def execute_search(search_term, page=1)
        relation = search_relation(all_visible_relation, search_term)
        relation.length == 1 ?
          execute_show_item(relation) :
          execute_show_items(relation, page)
      end
      
    end
  end
end
Ricer4::Plugin.extend(Ricer4::Extend::IsSearchTrigger)
