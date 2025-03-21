module NumericMixin
  # Trap missing method calls and look for methods that look like unit names
  def method_missing(id, *args, &block)
    if !block_given? && Units.valid_unit?(id)
      units = Units.new(args.empty? ? id : {id => args[0]})

      # Float and Fixnum need to be handled specially because they're
      #  treated as literals by the interpreter. Specifically, all
      #  literals with the same value are considered to be the same
      #  instance. Consequently, any instance variable (such as @units)
      #  added to a literal becomes available to all literals of the
      #  same value.
      if self.is_a?(Integer) || self.is_a?(Float) || self.is_a?(Rational)
        Units::Numeric.new(self, units)	# Create a new wrapper object
      else
        # Check that the class hasn't already been patched
        #  Numeric's subclasses are patched here, instead of at load-time,
        #  to automatically support any future Numeric subclasses without
        #  requiring changes to this module
        self.class.send(:include, UnitsMixin) unless self.kind_of?(UnitsMixin)
        @units = units
        self
      end
    else
      super if defined?(super)
    end
  end
end
