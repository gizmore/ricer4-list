class ActiveRecord::Magic::Param::Position < ActiveRecord::Magic::Param::Integer
  
    def default_options; { min: 1, multiple: false }; end

end