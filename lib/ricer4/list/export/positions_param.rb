load File.expand_path("../range.rb", __FILE__)
class ActiveRecord::Magic::Param::Positions < Ricer4::Parameter
  
    def default_options; { valid_range_function: nil }; end
    
    def doing_multiple?; true; end
    
    def input_to_values(input)
      result = Ricer4::Range.new
      input.split(',').each do |token|
        t = token.split('-')
        t.push(t[0]) if t.length == 1
        t[0] = t[0].to_i; t[1] = t[1].to_i
        t[0],t[1] = t[1],t[0] if t[0] > t[1]
        result += t[0]..t[1]
      end
      result
    end
    
    def values_to_input(values)
      return '' if values.nil?
      byebug # XXX: UNTESTED
      values.map{|v|v.to_s}.join(',') unless values.nil?
    end
    
    def validate!(ranges)
      invalid! unless ranges.is_a?(Ricer4::Range)
      validate_ranges!(ranges) if @plugin && @options[:valid_range_function] && @plugin.respond_to?(@options[:valid_range_function])
    end
    
    def validate_ranges!(ranges)
      ranges.enumerators.each do |range|
        invalid!(:err_invalid_range, range: range.to_s) unless @plugin.send(@options[:valid_range_function], range)
      end
    end

end