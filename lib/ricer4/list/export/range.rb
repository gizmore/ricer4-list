class Ricer4::Range
  
  attr_reader :enumerators

  def initialize
    @enumerators = []
  end
  
  def +(range)
    if range.is_a?(::Range)
      @enumerators.push(range)
    else
      @enumerators.push(Array(range))
    end
    self
  end
  
  def each(&block)
    enumerator.each do |number|
      yield number
    end
  end
  
  def enumerator
    Enumerator.new do |y|
      yielded = []
      @enumerators.each do |enumerator|
        enumerator.each do |element|
          unless yielded.include?(element)
            yielded.push(element)
            y.yield(element)
          end
        end
      end
    end
  end
end
