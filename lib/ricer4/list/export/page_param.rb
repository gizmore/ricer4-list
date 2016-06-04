class ActiveRecord::Magic::Param::Page < ActiveRecord::Magic::Param::Integer
  
  def default_options
    super.reverse_merge({ min: 1, default: 1 })
  end
  
end