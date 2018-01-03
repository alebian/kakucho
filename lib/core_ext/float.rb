class Float
  # Round a number up
  #
  #   12.34.round_up(1)  # => 12.4
  #   12.34.round_up(2)  # => 12.35
  #   12.34.round_up(3)  # => 12.341
  def round_up(decimals)
    (self + 10**(-1 * decimals)).round(decimals)
  end
end
