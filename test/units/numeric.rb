require 'matrix'
require 'minitest/autorun'
require 'units/numeric'

describe Units::Numeric do
  let(:one)	{ Units::Numeric.new(1) }
  let(:three)	{ Units::Numeric.new(3) }
  let(:four)	{ Units::Numeric.new(4) }
  let(:seven)	{ Units::Numeric.new(7) }
  let(:twelve){ Units::Numeric.new(12) }

  let(:three_inches)	{ Units::Numeric.new(3, :inches) }
  let(:four_inches)	{ Units::Numeric.new(4, :inches) }

  let(:one_meter)	{ Units::Numeric.new(1, :meter) }
  let(:three_meters)	{ Units::Numeric.new(3, :meters) }
  let(:four_meters)	{ Units::Numeric.new(4, :meters) }
  let(:six_meters)	{ Units::Numeric.new(6, :meters) }
  let(:seven_meters)	{ Units::Numeric.new(7, :meters) }
  let(:twelve_meters)	{ Units::Numeric.new(12, :meters) }

  let(:twelve_meters2)    { Units::Numeric.new(12, Units.new(:meters, :meters)) }

  it "should claim to be a Numeric" do
    assert_kind_of Numeric, one
  end

  describe "when constructing" do
    it "should require a value" do
      assert_raises(ArgumentError) { Units::Numeric.new }
    end

    it "should accept a Unit, but not require it" do
      assert_equal Units::Numeric.new(1), 1
      assert_equal Units::Numeric.new(1, :meter), one_meter
    end
  end

  describe "equality" do
    let(:three_inches)	{ Units::Numeric.new(3, :inches) }
    let(:three_meters)	{ Units::Numeric.new(3, :meters) }

    it "must equate zero-with-units and zero" do
      assert_equal 0.meters, 0
    end

    it "should not equate a literal with units and a literal without units" do
      refute_equal three_meters, 3
    end

    it "should not equate meters with inches" do
      refute_equal three_meters, three_inches
      refute_equal three_inches, three_meters
    end

    it "should preserve normal equality for literals without units" do
      assert_equal three, three
      assert_equal Units::Numeric.new(3), 3
      assert_equal Units::Numeric.new(3.5), 3.5
    end
  end

  describe "arithmetic without units" do
    it "should preserve integer addition" do
      assert_equal three + four, seven
    end

    it "should preserve integer subtraction" do
      assert_equal four - three, one
      assert_equal three - four, -one
    end

    it "should preserve integer multiplication" do
      assert_equal three * four, twelve
    end

    it "should preserve integer division" do
      assert_equal twelve/four, three
    end
  end

  describe "arithmetic with like units" do
    it "should support addition" do
      assert_equal three_meters + four_meters, seven_meters
    end

    it "should support subtraction" do
      assert_equal four_meters - three_meters, one_meter
      assert_equal 0.meters - four_meters, -four_meters
    end

    it "should support multiplication" do
      assert_equal 3.meters * 4.meters, twelve_meters2
    end

    it "should support division" do
      assert_equal twelve_meters / three_meters, 4
      assert_equal 0.meters / 3.meters, 0
    end

    it 'must support exponentiation' do
      assert_equal 3.meters**2, 9.meters(2)
      assert_equal Rational(3,1).meters**2, Rational(9,1).meters(2)
    end
  end

  describe "coerced arithmetic" do
    it "addition" do
      assert_equal 4 + three_meters, seven_meters
    end

    it "subtraction" do
      assert_equal 4 - three_meters, one_meter
      assert_equal 0 - four_meters, -four_meters
    end

    it "multiplication" do
      assert_equal 4 * three_meters, twelve_meters
    end

    it "division" do
      assert_equal 0 / one_meter, 0
      assert_equal 0 / three_meters, 0
      assert_equal 4 / three_meters, one_meter
      assert_equal 12.0 / three_meters, four_meters
    end

    it "must divide a Rational" do
      assert_equal Rational(2,1) / one_meter, Rational(2,1).meters(-1)
    end

  end

  describe "integer arithmetic with normal literals" do
    it "should support multiplication" do
      assert_equal three_meters * 4, twelve_meters
      assert_equal three_meters * four, twelve_meters
    end

    it "support division" do
      assert_equal twelve_meters / 3, four_meters
      assert_equal one_meter / 2, 0.meters
    end
  end

  describe "arithmetic with mixed units" do
    it "should allow addition of valid units and no units" do
      assert_equal three_meters + four, seven_meters
      assert_equal four + three_meters, seven_meters
    end

    it "should allow subtraction of valid units and no units" do
      assert_equal three_meters - three, 0.meters
      assert_equal three - three_meters, 0.meters
    end

    it "should reject mixed units when adding" do
      assert_raises(UnitsError) { three_meters + three_inches }
    end

    it "should reject mixed units when subtracting" do
      assert_raises(UnitsError) { three_meters - four_inches }
    end

    it "must return a Vector when multiplying a Vector" do
      v = (three_meters * Vector[1,2])
      assert_kind_of Vector, v
      assert_equal v[0], three_meters
      assert_equal v[1], six_meters
    end
  end

  describe "comparison" do
    describe "spaceship" do
      it "must spaceship with like units" do
        assert_equal three_meters <=> four_meters, -1
        assert_equal three_meters <=> three_meters, 0
        assert_equal four_meters <=> three_meters, 1
      end

      it "must not spaceship with unlike units" do
        assert_nil three_meters <=> three_inches
      end

      it "must spaceship with unitless literals" do
        assert_equal three_meters <=> 4, -1
        assert_equal three_meters <=> 3, 0
        assert_equal four_meters <=> 3, 1
      end

      it "must reverse spaceship with unitless literals" do
        assert_equal 3 <=> four_meters, -1
        assert_equal 3 <=> three_meters, 0
        assert_equal 4 <=> three_meters, 1
      end
    end
  end

  it "must square root" do
    assert_equal Math.sqrt(three_meters*three_meters), three_meters
  end

  it "should have an inspect method" do
    assert_equal('1 meter', one_meter.inspect)
    assert_equal(1, one);
  end
  it "should have a to_s method that returns only the literal's to_s" do
    assert_equal('1', one_meter.to_s)
  end

  describe "when converting to other units" do
    it "must convert to different units" do
      assert_equal one_meter.to_inches, 39.3701.inches
    end

    it "must do nothing when converting to identical units" do
      assert_equal one_meter.to_meters, one_meter
    end

    it "must handle prefix-only conversions" do
      assert_equal one_meter.to_millimeters, 1000.mm
    end

    it "must handle mixed prefix conversions" do
      assert_equal 100.cm.to_inches, 39.3701.inches
      assert_equal 100.inches.to_centimeters, 254.cm
    end

    it "must handle converting to abbreviated units" do
      assert_equal 100.cm.to_mm, 1000.mm
    end

    it "must reject invalid target units" do
      assert_raises(NoMethodError) { 100.cm.to_foo }
    end
  end

  describe 'when converting to other units without the to_ prefix' do
    it 'must convert to different units' do
      assert_equal one_meter.inches, 39.3701.inches
    end

    it 'must do nothing when converting to identical units' do
      assert_equal one_meter.meters, one_meter
    end

    it 'must handle prefix-only conversions' do
      assert_equal one_meter.millimeters, 1000.mm
    end

    it 'must handle mixed prefix conversions' do
      assert_equal 100.cm.inches, 39.3701.inches
      assert_equal 100.inches.centimeters, 254.cm
    end

    it 'must handle converting to abbreviated units' do
      assert_equal 100.cm.mm, 1000.mm
    end

    it 'must reject invalid target units' do
      assert_raises(NoMethodError) { 100.cm.foo }
    end
  end

  describe 'when asked about its units' do
    it 'must be degrees' do
      assert_equal 90.degrees.degrees?, true
    end

    it 'must be meters' do
      assert_equal 1.meter.meters?, true
    end

    it 'must be inches' do
      assert_equal 1.inch.inch?, true
    end
  end
end
