require_relative '../units'

class Units
    class Numeric < Numeric
	attr_reader :units, :value

	def initialize(value, units=nil)
	    @value = value
	    @units = (units.is_a?(Units) ? units : Units.new(units)) if units
	end

	# Handle conversion methods (to_*) and pass everything else to the wrapped value
	def method_missing(id, *args)
	    # Check this before valid_conversion? because valid_conversion? has low standards
	    if (id.to_s =~ /(.+)\?$/) and Units.valid_unit?($1)
		@units.is_a?($1)
	    elsif @units.valid_conversion?(id)
		units = Units.new(id)
		(@units == units) ? self : self.class.new(@units.convert(@value, id), units)
	    elsif (id.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1)
		units = Units.new($1)
		return self if @units == units
		self.class.new(@units.convert(@value, $1), units)
	    else
		@value.send(id, *args)
	    end
	end

	def inspect
	    if @units
		@value.inspect + ' ' + @units.inspect
	    else
		@value.inspect
	    end
	end
	def to_s
	    @value.to_s
	end

	# Convert other into something that can handle being divided by {Numeric}
	def coerce(other)
	    case other
		when Integer then [Numeric.new(other), self]
		when Float  then [Numeric.new(other), self]
		else
		    other.class.send(:include, UnitsMixin) unless other.kind_of?(UnitsMixin)
		    [other, self]
	    end
	end

	# Both the values and the units must match for two numbers to be considered equal
	#  ie. 3.meters != 3.inches != 3
	# However, 0.units == 0 is a special case to avoid breaking any conditionals
	# that attempt to avoid dividing by zero
	def eql?(other)
	    if other.respond_to?(:units)
		(@units == other.units) and (@value == other.value)
	    elsif other == 0
		@value == other
	    else
		(@units == nil) and (@value == other)
	    end
	end
	alias == eql?

	def <=>(other)
	    if other.kind_of? Numeric
		if @units
		    @units.eql?(other.units) ? (@value <=> other.value) : nil
		else
		    (@value <=> other.value)
		end
	    elsif other.respond_to? :map
		other.map {|a| self.send(:<=>, a)}
	    else
		@value <=> other
	    end
	end

	# @group Arithmetic
	def +(other)
	    op(:+, other)
	end

	def -(other)
	    op(:-, other)
	end

	def *(other)
	    op(:*, other)
	end

	def /(other)
	    op(:/, other)
	end

	def **(power)
	    self.class.new(@value ** power, @units ? (@units ** power) : nil)
	end
	# @endgroup

	private

	# Generic operator handler
	def op(sym, other)
	    if other.kind_of? Numeric
		self.class.new(@value.send(sym, other.value), @units ? (@units.send(sym, other.units)) : ((:/ == sym) && (0 == @value) ? nil : other.units))
	    elsif other.respond_to? :map
		other.map {|a| self.send(sym, a)}
	    else
		self.class.new(@value.send(sym, other), @units ? (@units.send(sym, other.units)) : other.units)
	    end
	rescue UnitsError
	    raise
	rescue ArgumentError    # Handle units that cancel out
	    @value.send(sym, other.value)
	rescue NoMethodError
	    self.class.new(@value.send(sym, other), @units)
	end
    end
end
