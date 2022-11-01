require 'minitest/autorun'
require 'units'

describe Units do
  describe "when validating strings" do
    let(:units_s)   { Units::UNITS.map {|u| (u.to_s + 's').to_sym } }
    let(:units_es)  { Units::UNITS.map {|u| (u.to_s + 'es').to_sym } }

    it "should accept all valid units" do
      Units::UNITS.each {|unit| assert_equal Units.valid_unit?(unit), (true) }
    end

    it "should accept all valid plural units" do
      (units_s + units_es).each {|u| assert_equal Units.valid_unit?(u), (true) }
    end

    it "should accept all valid prefixed units" do
      all = Units::UNITS.map {|u| Units::PREFIXES.keys.map {|p| p.to_s + u.to_s } }
      all.flatten.each {|u| assert_equal Units.valid_unit?(u.to_sym), (true) }
    end

    it "should accept all valid abbreviations" do
      Units::ABBREVIATIONS.keys.each {|a| assert_equal Units.valid_unit?(a), (true) }
    end

    it "reject invalid units" do
      refute_equal Units.valid_unit?(:foo), (true)
    end

    it "reject invalid prefix" do
      refute_equal Units.valid_unit?(:foometer), (true)
    end
  end

  describe "when constructing" do
    let(:meter_hash) { {:meters => 1} }
    let(:meter_inch_hash) { {:meters => 1, :inches => 1} } 

    it "should accept valid units hash" do
      assert_equal Units.new(:meter_hash), Units.new(:meters => 1)
    end

    it "should accept valid units hashification" do
      assert_equal Units.new(:meters => 1, :inches => 1), Units.new(meter_inch_hash)
    end

    it "should accept valid units arrayification" do
      assert_equal Units.new(:meters, :inches), Units.new(meter_inch_hash)
    end

    it "should accept valid units strings" do
      Units::UNITS.each {|unit| assert_equal Units.new(unit.to_s), Units.new({unit => 1}) }
    end

    it "should accept valid units symbols with unitary exponents" do
      Units::UNITS.each {|unit| assert_equal Units.new(unit), Units.new({unit => 1}) }
    end

    it "should reject nil units" do
      assert_raises(ArgumentError) { Units.new(nil) }
    end

    it "should reject a units hash with zeroed exponents" do
      assert_raises(ArgumentError) { Units.new({:meters => 0}) }
      assert_raises(ArgumentError) { Units.new({:meters => 0, :inches => 0}) }
    end

    it "should reject an empty units hash" do
      assert_raises(ArgumentError) { Units.new({}) }
    end

    it "should reject a hash with invalid units" do
      assert_raises(UnitsError) { Units.new({:foo => 1}) }
    end

    it "should reject an empty string" do
      assert_raises(UnitsError) { Units.new('') }
    end

    it "should reject a string with an invalid unit" do
      assert_raises(UnitsError) { Units.new('foo') }
    end

    it "should reject an invalid units symbol" do
      assert_raises(UnitsError) { Units.new(:foo) }
    end

    it "ignore hash keys with zero value" do
      meter = Units.new(:meters)
      assert_equal Units.new(:meters => 1, :inches => 0), meter
      refute_equal Units.new(:meters => 1, :inches => 1), meter
    end

    it "must have a convenience method for instantiating units" do
      assert_equal Units.meter, Units.new(:meters)
      assert_equal Units.mm, Units.new(:millimeters)
    end
  end

  describe "equality" do
    let(:meter) { Units.new(:meters) }
    let(:inch) { Units.new(:inch) }

    it "equal units must be equal" do
      assert_equal meter, meter
    end

    it "unequal units must be unequal" do
      refute_equal meter, inch
    end

    it "should preserve case equality" do
      assert_equal meter === meter, true
      refute_equal meter === inch, true
      refute_equal inch === meter, true
    end

    it "should not equal nil" do
      refute_nil meter
    end
  end

  describe 'arithmetic with like units' do
    it 'must exponentiate' do
      assert_equal Units.meters**2, Units.new(meters:2)
    end
  end

  describe "arithmetic with mixed units" do
    let(:meter) { Units.new(:meters) }

    it "should multiply" do
      assert_equal meter * Units.new(:inches), Units.new(:meters => 1, :inches => 1)
    end

    it "should multiply by nil" do
      assert_equal meter * nil, meter
    end

    it "should divide by nil" do
      assert_equal meter / nil, meter
    end
  end

  describe "comparison" do
    describe "spaceship" do
      it "must return 0 for equal units" do
        assert_equal Units.new(:meters) <=> Units.new(:meters), 0
      end

      it "must return nil for unequal units" do
        assert_nil Units.new(:meters) <=> Units.new(:inches)
      end
    end
  end

  describe "conversion" do
    it "should have an inspect method" do
      assert_equal Units.new('meters').inspect, 'meter'
    end

    it "should have a to_s method" do
      assert_equal Units.new('meters').to_s, 'meter'
    end

    it "should have a to_abbreviation method" do
      assert_equal Units.new('centimeters').to_abbreviation, 'cm'
    end

    it "must have a convert method that converts a value to new units" do
      assert_equal Units.meter.convert(10, 'inch'), 393.701
    end

    it 'must convert degrees to radians' do
      assert_in_epsilon 90.degrees.radians, Math::PI/2
    end
  end

  it "must square root" do
    assert_equal (Units.new('meters')*Units.new('meters')).square_root, Units.new('meters')
  end

  describe 'when checking conversion validity' do
    it 'must accept inches and meters' do
      assert_equal Units.meter.valid_conversion?('inch'), true
      assert_equal Units.inch.valid_conversion?('meter'), true
      assert_equal Units.meter.valid_conversion?(:inch), true
      assert_equal Units.inch.valid_conversion?(:meter), true
    end

    it 'must accept conversion to self' do
      assert_equal Units.meter.valid_conversion?(:meter), true
      assert_equal Units.meter.valid_conversion?(:mm), true
    end

    it 'must accept mixed prefixes' do
      assert_equal Units.inch.valid_conversion?(:mm), true
    end

    it 'must reject nonsense conversions' do
      assert_equal Units.meter.valid_conversion?(:foo), false
    end

    it 'must reject invalid conversions' do
      assert_nil Units.meter.valid_conversion?(:hertz)
    end
  end

  describe 'when overriding is_a?' do
    it 'must be a base unit' do
      assert_equal Units.meters.is_a?(:meters), true
    end

    it 'must be a prefixed unit' do
      assert_equal Units.mm.is_a?(:meters), true
    end
  end
end
