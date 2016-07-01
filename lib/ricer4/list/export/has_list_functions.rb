module Ricer4::Extend::HasListFunctions
  def has_list_functions(options)
    class_eval do |klass|
      # Sanity
      if options[:for] != true ### SKIP for runtime choice
        throw "#{klass.name} is_list_trigger #{options[:for]} class is not an ActiveRecord::Base" unless options[:for] < ActiveRecord::Base
      end
      unless options[:per_page].to_i.between?(1, 100)
        throw "#{klass.name} is_list_trigger has invalid per_page option: #{options[:per_page]}"
      end
      
      # Register vars exist in class for reloading code
      klass.define_class_variable('@search_class', options[:for])
      klass.define_class_variable('@list_per_page', options[:per_page].to_i)
      klass.define_class_variable('@list_ordering', options[:order])

      protected

      def raise_record_not_found
        raise Ricer4::ExecutionException.new(tr('extender.is_list_trigger.err_not_found',
          classname: search_class_name,
        ))
      end
      
      def search_class_name
        search_class.model_name.human
      end

      #################
      ### Relations ###
      #################
      def list_ordering
        self.class.instance_variable_get('@list_ordering')
      end
      
      def list_per_page
        self.class.instance_variable_get('@list_per_page')
      end
      
      def search_class
        self.class.instance_variable_get('@search_class')
      end
      
      def search_relation(relation, arg)
        return relation.search(arg) if relation.respond_to?(:search)
        relation.where(:id => arg)
      end
      
      def order_relation(relation)
        relation.order(list_ordering)
      end
      
      def visible_relation(relation)
        return relation.visible(user) if relation.respond_to?(:visible)
        relation
      end
      
      def all_visible_relation
        order_relation(visible_relation(search_class))
      end

      ###############
      ### Display ###
      ###############
      def display_list_item(item, number)
        "#{number}-#{item.class.name}"
      end

      def display_show_item(item, number)
        "#{number}-#{item.inspect}"
      end
      
      #####################
      ### List Position ###
      #####################
      def calc_item_position(item)
        calc_item_positions([item]).first
      end
      
      def calc_item_positions(items)
        positions = []
        unless items.empty?
          all_visible_relation.each_with_index do |visible, number|
            if (calc_item_equal(visible, items[positions.length]))
              positions.push(number+1)
              break if items[positions.length].nil?
            end
          end
        end
        positions
      end
      
      def calc_item_equal(item1, item2)
        (item1 == item2) ||
        ((item1.id) && (item1.id == item2.id)) ||
        (show_item_string(item1) == show_item_string(item2))
      end
      
      ####################
      ### Exec helpers ###
      ####################
      def execute_show_item(relation)
        item = relation.first or raise_record_not_found
        number = calc_item_position(item)
        reply show_item_string(item, number)
      end
      
      def show_item_string(item, number=0)
        if item.respond_to?(:display_show_item)
          item.display_show_item(number)
        else
          display_show_item(item, number)
        end
      end
      
      def page_relation(relation, page)
        if (relation.is_a?(Array))
          page_relation_array(relation, page)
        else
          relation.page(page.to_i).per(list_per_page).all
        end
      end
      
      def page_relation_array(relation, page)
        per_page = list_per_page
        start = per_page * (page - 1)
        endin = start + per_page
        Array(relation[start...endin])
      end
      
      def total_pages(relation)
        ((relation.length - 1) / list_per_page) + 1
      end
      
      def total_items(relation)
        relation.count
      end
      
      def execute_show_items(relation, page)
        # Load search result
        items = page_relation(relation, page)
        # Compute positions
        positions = calc_item_positions(items)
        # Output
        out = []
        items.each do |item|
          if item.respond_to?(:display_list_item)
            out.push(item.display_list_item(positions.shift))
          else
            out.push(display_list_item(item, positions.shift))
          end
        end
        if out.length == 0
          rplyr 'extender.is_list_trigger.err_no_list_items',
            classname: search_class_name 
        else
          rplyr 'extender.is_list_trigger.msg_list_item_page',
            classname: search_class_name,
            page: page,
            pages: total_pages(relation),
            items: total_items(relation),
            out: out.join(', ')
        end
      end

    end
  end
end
Ricer4::Plugin.extend(Ricer4::Extend::HasListFunctions)
