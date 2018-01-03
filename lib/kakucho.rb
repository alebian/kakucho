require_relative 'core_ext/array'
require_relative 'core_ext/float'
require_relative 'core_ext/hash'
require_relative 'core_ext/string'

module Kakucho
  module_function

  def deep_clone(obj)
    Marshal.load(Marshal.dump(obj))
  end
end