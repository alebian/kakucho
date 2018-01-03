class Integer
  # Check whether the integer is evenly divisible by the argument.
  #
  #   0.multiple_of?(0)  # => true
  #   6.multiple_of?(5)  # => false
  #   10.multiple_of?(2) # => true
  def multiple_of?(number)
    number != 0 ? self % number == 0 : zero?
  end

  def prime?(number)
    return false if number <= 1
    return true if number == 2
    maximum = Math.sqrt(number).to_i + 1
    (2..maximum).each do |i|
      return false if number % i == 0
    end
    true
  end
end