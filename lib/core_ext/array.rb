class Array
  # Puts the element passed by argument at the beginning of the array
  #
  # [1, 2, 3].promote(2) => [2, 1, 3]
  # [1, 2, 3].promote(nil) => [1, 2, 3]
  #
  # [{ id: 1, id: 2 }].promote { |a| a[:id] == 2 } => [{ id: 2, id: 1 }]
  def promote(promoted_element = nil, &block)
    found_index = index &block if block_given?
    found_index = find_index(promoted_element) unless block_given?
    return self unless found_index
    unshift(delete_at(found_index))
  end

  # The human way of thinking about adding stuff to the end of a list is with append.
  alias_method :append,  :push unless [].respond_to?(:append)

  # The human way of thinking about adding stuff to the beginning of a list is with prepend.
  alias_method :prepend, :unshift unless [].respond_to?(:prepend)

  # An array is blank if it's empty:
  #
  #   [].blank?      # => true
  #   [1,2,3].blank? # => false
  #
  # @return [true, false]
  alias_method :blank?, :empty?
end
