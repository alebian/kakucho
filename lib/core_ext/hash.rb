class Hash
  unless Hash.instance_methods(false).include?(:compact)
    # Returns a hash with non +nil+ values.
    #
    #   hash = { a: true, b: false, c: nil }
    #   hash.compact        # => { a: true, b: false }
    #   hash                # => { a: true, b: false, c: nil }
    #   { c: nil }.compact  # => {}
    #   { c: true }.compact # => { c: true }
    def compact
      select { |_, value| !value.nil? }
    end
  end

  unless Hash.instance_methods(false).include?(:compact!)
    # Replaces current hash with non +nil+ values.
    # Returns +nil+ if no changes were made, otherwise returns the hash.
    #
    #   hash = { a: true, b: false, c: nil }
    #   hash.compact!        # => { a: true, b: false }
    #   hash                 # => { a: true, b: false }
    #   { c: true }.compact! # => nil
    def compact!
      reject! { |_, value| value.nil? }
    end
  end

  # Returns a hash that includes everything except given keys.
  #   hash = { a: true, b: false, c: nil }
  #   hash.except(:c)     # => { a: true, b: false }
  #   hash.except(:a, :b) # => { c: nil }
  #   hash                # => { a: true, b: false, c: nil }
  #
  # This is useful for limiting a set of parameters to everything but a few known toggles:
  #   @person.update(params[:person].except(:admin))
  def except(*keys)
    dup.except!(*keys)
  end

  # Removes the given keys from hash and returns it.
  #   hash = { a: true, b: false, c: nil }
  #   hash.except!(:c) # => { a: true, b: false }
  #   hash             # => { a: true, b: false }
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  #
  #   h1 = { a: true, b: { c: [1, 2, 3] } }
  #   h2 = { a: false, b: { x: [3, 4, 5] } }
  #
  #   h1.deep_merge(h2) # => { a: false, b: { c: [1, 2, 3], x: [3, 4, 5] } }
  #
  # Like with Hash#merge in the standard library, a block can be provided
  # to merge values:
  #
  #   h1 = { a: 100, b: 200, c: { c1: 100 } }
  #   h2 = { b: 250, c: { c1: 200 } }
  #   h1.deep_merge(h2) { |key, this_val, other_val| this_val + other_val }
  #   # => { a: 100, b: 450, c: { c1: 300 } }
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  # Same as +deep_merge+, but modifies +self+.
  def deep_merge!(other_hash, &block)
    merge!(other_hash) do |key, this_val, other_val|
      if this_val.is_a?(Hash) && other_val.is_a?(Hash)
        this_val.deep_merge(other_val, &block)
      elsif block_given?
        block.call(key, this_val, other_val)
      else
        other_val
      end
    end
  end

  # Slices a hash to include only the given keys. Returns a hash containing
  # the given keys.
  #
  #   { a: 1, b: 2, c: 3, d: 4 }.slice(:a, :b)
  #   # => {:a=>1, :b=>2}
  #
  # This is useful for limiting an options hash to valid keys before
  # passing to a method:
  #
  #   def search(criteria = {})
  #     criteria.assert_valid_keys(:mass, :velocity, :time)
  #   end
  #
  #   search(options.slice(:mass, :velocity, :time))
  #
  # If you have an array of keys you want to limit to, you should splat them:
  #
  #   valid_keys = [:mass, :velocity, :time]
  #   search(options.slice(*valid_keys))
  def slice(*keys)
    keys.each_with_object(Hash.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end unless method_defined?(:slice)

  # Replaces the hash with only the given keys.
  # Returns a hash containing the removed key/value pairs.
  #
  #   { a: 1, b: 2, c: 3, d: 4 }.slice!(:a, :b)
  #   # => {:c=>3, :d=>4}
  def slice!(*keys)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    hash.default      = default
    hash.default_proc = default_proc if default_proc
    replace(hash)
    omit
  end

  # Removes and returns the key/value pairs matching the given keys.
  #
  #   { a: 1, b: 2, c: 3, d: 4 }.extract!(:a, :b) # => {:a=>1, :b=>2}
  #   { a: 1, b: 2 }.extract!(:a, :x)             # => {:a=>1}
  def extract!(*keys)
    keys.each_with_object(self.class.new) { |key, result| result[key] = delete(key) if has_key?(key) }
  end

  # Returns a new hash with all keys converted by the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #  hash = { person: { name: 'Rob', age: '28' } }
  #
  #  hash.deep_transform_keys{ |key| key.to_s.upcase }
  #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  # Destructively converts all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end

  # Returns a new hash with all keys converted to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #   hash = { person: { name: 'Rob', age: '28' } }
  #
  #   hash.deep_stringify_keys
  #   # => {"person"=>{"name"=>"Rob", "age"=>"28"}}
  def deep_stringify_keys
    deep_transform_keys(&:to_s)
  end

  # Destructively converts all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_stringify_keys!
    deep_transform_keys!(&:to_s)
  end

  # Returns a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+. This includes the keys from the root hash
  # and from all nested hashes and arrays.
  #
  #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
  #
  #   hash.deep_symbolize_keys
  #   # => {:person=>{:name=>"Rob", :age=>"28"}}
  def deep_symbolize_keys
    deep_transform_keys { |key| key.to_sym rescue key }
  end

  # Destructively converts all keys to symbols, as long as they respond
  # to +to_sym+. This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_symbolize_keys!
    deep_transform_keys! { |key| key.to_sym rescue key }
  end

  # A hash is blank if it's empty:
  #
  #   {}.blank?                # => true
  #   { key: 'value' }.blank?  # => false
  #
  # @return [true, false]
  alias_method :blank?, :empty?

  private
   
  # support methods for deep transforming nested hashes and arrays
  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  def _deep_transform_keys_in_object!(object, &block)
    case object
    when Hash
      object.keys.each do |key|
        value = object.delete(key)
        object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
      end
      object
    when Array
      object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
    else
      object
    end
  end
end
