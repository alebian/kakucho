class String
  BLANK_RE = /\A[[:space:]]*\z/
  BOOLEANS = {
      'true' => true, 'True' => true
  }.freeze
  ASCII_ENCODING = {
    ' ' => '%20',
    '!' => '%21',
    '"' => '%22',
    '#' => '%23',
    '$' => '%24',
    '%' => '%25',
    '&' => '%26',
    "'" => '%27',
    '(' => '%28',
    ')' => '%29',
    '*' => '%2A',
    '+' => '%2B',
    ',' => '%2C',
    '-' => '%2D',
    '.' => '%2E',
    '/' => '%2F',
    '0' => '%3',
    ':' => '%3A',
    ';' => '%3B',
    '<' => '%3C',
    '=' => '%3D',
    '>' => '%3E',
    '?' => '%3F',
    '@' => '%4',
    '[' => '%5B',
    "\\" => '%5C',
    ']' => '%5D',
    '^' => '%5E',
    '_' => '%5F',
    '`' => '%6',
    '{' => '%7B',
    '|' => '%7C',
    '}' => '%7D',
    '~' => '%7',
    '`' => '%80',
    '' => '%81',
    '‚' => '%8'
  }.freeze
  
  def to_bool
    BOOLEANS.fetch(self, false)
  end

  # A string is blank if it's empty or contains whitespaces only:
  #
  #   ''.blank?       # => true
  #   '   '.blank?    # => true
  #   "\t\n\r".blank? # => true
  #   ' blah '.blank? # => false
  #
  # Unicode whitespace is supported:
  #
  #   "\u00a0".blank? # => true
  #
  # @return [true, false]
  def blank?
    # The regexp that matches blank strings is expensive. For the case of empty
    # strings we can speed up this method (~3.5x) with an empty? call. The
    # penalty for the rest of strings is marginal.
    empty? || BLANK_RE.match?(self)
  end

  # If you pass a single integer, returns a substring of one character at that
  # position. The first character of the string is at position 0, the next at
  # position 1, and so on. If a range is supplied, a substring containing
  # characters at offsets given by the range is returned. In both cases, if an
  # offset is negative, it is counted from the end of the string. Returns +nil+
  # if the initial offset falls outside the string. Returns an empty string if
  # the beginning of the range is greater than the end of the string.
  #
  #   str = "hello"
  #   str.at(0)      # => "h"
  #   str.at(1..3)   # => "ell"
  #   str.at(-2)     # => "l"
  #   str.at(-2..-1) # => "lo"
  #   str.at(5)      # => nil
  #   str.at(5..-1)  # => ""
  #
  # If a Regexp is given, the matching portion of the string is returned.
  # If a String is given, that given string is returned if it occurs in
  # the string. In both cases, +nil+ is returned if there is no match.
  #
  #   str = "hello"
  #   str.at(/lo/) # => "lo"
  #   str.at(/ol/) # => nil
  #   str.at("lo") # => "lo"
  #   str.at("ol") # => nil
  def at(position)
    self[position]
  end

  # Returns a substring from the given position to the end of the string.
  # If the position is negative, it is counted from the end of the string.
  #
  #   str = "hello"
  #   str.from(0)  # => "hello"
  #   str.from(3)  # => "lo"
  #   str.from(-2) # => "lo"
  #
  # You can mix it with +to+ method and do fun things like:
  #
  #   str = "hello"
  #   str.from(0).to(-1) # => "hello"
  #   str.from(1).to(-2) # => "ell"
  def from(position)
    self[position..-1]
  end

  # Returns a substring from the beginning of the string to the given position.
  # If the position is negative, it is counted from the end of the string.
  #
  #   str = "hello"
  #   str.to(0)  # => "h"
  #   str.to(3)  # => "hell"
  #   str.to(-2) # => "hell"
  #
  # You can mix it with +from+ method and do fun things like:
  #
  #   str = "hello"
  #   str.from(0).to(-1) # => "hello"
  #   str.from(1).to(-2) # => "ell"
  def to(position)
    self[0..position]
  end

  # Returns the first character. If a limit is supplied, returns a substring
  # from the beginning of the string until it reaches the limit value. If the
  # given limit is greater than or equal to the string length, returns a copy of self.
  #
  #   str = "hello"
  #   str.first    # => "h"
  #   str.first(1) # => "h"
  #   str.first(2) # => "he"
  #   str.first(0) # => ""
  #   str.first(6) # => "hello"
  def first(limit = 1)
    if limit == 0
      ""
    elsif limit >= size
      dup
    else
      to(limit - 1)
    end
  end

  # Returns the last character of the string. If a limit is supplied, returns a substring
  # from the end of the string until it reaches the limit value (counting backwards). If
  # the given limit is greater than or equal to the string length, returns a copy of self.
  #
  #   str = "hello"
  #   str.last    # => "o"
  #   str.last(1) # => "o"
  #   str.last(2) # => "lo"
  #   str.last(0) # => ""
  #   str.last(6) # => "hello"
  def last(limit = 1)
    if limit == 0
      ""
    elsif limit >= size
      dup
    else
      from(-limit)
    end
  end

  # Returns the string, first removing all whitespace on both ends of
  # the string, and then changing remaining consecutive whitespace
  # groups into one space each.
  #
  # Note that it handles both ASCII and Unicode whitespace.
  #
  #   %{ Multi-line
  #      string }.squish                   # => "Multi-line string"
  #   " foo   bar    \n   \t   boo".squish # => "foo bar boo"
  def squish
    dup.squish!
  end

  # Performs a destructive squish. See String#squish.
  #   str = " foo   bar    \n   \t   boo"
  #   str.squish!                         # => "foo bar boo"
  #   str                                 # => "foo bar boo"
  def squish!
    gsub!(/[[:space:]]+/, " ")
    strip!
    self
  end

  # Returns a new string with all occurrences of the patterns removed.
  #   str = "foo bar test"
  #   str.remove(" test")                 # => "foo bar"
  #   str.remove(" test", /bar/)          # => "foo "
  #   str                                 # => "foo bar test"
  def remove(*patterns)
    dup.remove!(*patterns)
  end

  # Alters the string by removing all occurrences of the patterns.
  #   str = "foo bar test"
  #   str.remove!(" test", /bar/)         # => "foo "
  #   str                                 # => "foo "
  def remove!(*patterns)
    patterns.each do |pattern|
      gsub! pattern, ""
    end

    self
  end

  # Truncates a given +text+ after a given <tt>length</tt> if +text+ is longer than <tt>length</tt>:
  #
  #   'Once upon a time in a world far far away'.truncate(27)
  #   # => "Once upon a time in a wo..."
  #
  # Pass a string or regexp <tt>:separator</tt> to truncate +text+ at a natural break:
  #
  #   'Once upon a time in a world far far away'.truncate(27, separator: ' ')
  #   # => "Once upon a time in a..."
  #
  #   'Once upon a time in a world far far away'.truncate(27, separator: /\s/)
  #   # => "Once upon a time in a..."
  #
  # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "...")
  # for a total length not exceeding <tt>length</tt>:
  #
  #   'And they found that many people were sleeping better.'.truncate(25, omission: '... (continued)')
  #   # => "And they f... (continued)"
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || "..."
    length_with_room_for_omission = truncate_at - omission.length
    stop = \
      if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{self[0, stop]}#{omission}"
  end

  # Truncates a given +text+ after a given number of words (<tt>words_count</tt>):
  #
  #   'Once upon a time in a world far far away'.truncate_words(4)
  #   # => "Once upon a time..."
  #
  # Pass a string or regexp <tt>:separator</tt> to specify a different separator of words:
  #
  #   'Once<br>upon<br>a<br>time<br>in<br>a<br>world'.truncate_words(5, separator: '<br>')
  #   # => "Once<br>upon<br>a<br>time<br>in..."
  #
  # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "..."):
  #
  #   'And they found that many people were sleeping better.'.truncate_words(5, omission: '... (continued)')
  #   # => "And they found that many... (continued)"
  def truncate_words(words_count, options = {})
    sep = options[:separator] || /\s+/
    sep = Regexp.escape(sep.to_s) unless Regexp === sep
    if self =~ /\A((?>.+?#{sep}){#{words_count - 1}}.+?)#{sep}.*/m
      $1 + (options[:omission] || "...")
    else
      dup
    end
  end

  def url_safe
    ans = dup
    ASCII_ENCODING.each do |k, v|
      ans.gsub!(k, v)
    end
    dup
  end
end
