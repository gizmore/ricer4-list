module Ricer4::Extend::IsShowTrigger
  
  IS_SHOW_TRIGGER_OPTIONS ||= {
    position_pattern: '<positions|valid_range_function:"range_valid?">',
    pagination_pattern: nil,
    with_welcome: false,
    search_pattern: nil
  }
  
  def is_show_trigger(trigger_name, options={})
    class_eval do |klass|
      
      ActiveRecord::Magic::Options.merge(options, IS_SHOW_TRIGGER_OPTIONS, false)
      
      # Consume this away for "is_list_trigger"
      position_pattern = options.delete(:position_pattern)

      # No pagination without search for "is_ist_trigger"
      options[:pagination_pattern] = nil
      
      # We offer positional display
      if position_pattern
        klass.has_usage position_pattern, function: :execute_show_position
        def range_valid?(range)
          min, max = 1, all_visible_relation.count
          range.min.between?(min, max) && range.max.between?(min, max)
        end
        def execute_show_position(positions)
          positions.each do |position|
            execute_show_item(all_visible_relation.limit(1).offset(position-1))
          end
        end
      end

      # But the rest is quite the same as "is_list_trigger"
      klass.is_list_trigger(trigger_name, options)
      
      def execute_show(relation)
        execute_show_item(relation)
      end
      
    end
  end
end
Ricer4::Plugin.extend(Ricer4::Extend::IsShowTrigger)
