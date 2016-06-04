module Ricer4::Extend::IsListTrigger

  LIST_TRIGGER_OPTIONS ||= {
    :for => nil,
    per_page: 5,
    order: 'created_at',
    with_welcome: true,
    welcome_pattern: '',
    search_pattern: nil,#'<search_term>', # falsy to disable
    pagination_pattern: '<page>', # falsy to disable
  }
  
  def is_list_trigger(trigger_name, options={})
    class_eval do |klass|

      ActiveRecord::Magic::Options.merge(options, LIST_TRIGGER_OPTIONS)
      
      has_list_functions(options)

      ##############
      ### Plugin ###
      ##############
      trigger_is trigger_name
      
      ### 
      # No params
      if options[:with_welcome]
        klass.has_usage '', function: :execute_welcome
        def execute_welcome
          execute_list(1)
        end
      end
      
      ###
      # Paginated, all of them
      if options[:pagination_pattern]
        klass.has_usage options[:pagination_pattern], function: :execute_list
      end
      def execute_list(page)
        execute_show_items(all_visible_relation, page)
      end

      ###
      # Paginated, some of them with search
      if options[:search_pattern]
        klass.has_usage "#{options[:search_pattern]} <page>", function: :execute_search
        klass.has_usage "#{options[:search_pattern]}", function: :execute_search
        def execute_search(search_term, page=1)
          relation = search_relation(all_visible_relation, search_term)
          relation.count == 1 ?
            execute_show_item(relation) :
            execute_show_items(relation, page)
        end
      end
      
    end
  end
end
Ricer4::Plugin.extend(Ricer4::Extend::IsListTrigger)
