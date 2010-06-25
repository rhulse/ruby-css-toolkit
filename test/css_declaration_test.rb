require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssDeclarationTest < Test::Unit::TestCase

	def test_declaration
		declaration = CssToolkit::Declaration.new('margin', '5px')
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_one
		declaration = CssToolkit::Declaration.new('margin', '10px 0 0 0')
		expected = "margin:10px 0 0 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_two
		declaration = CssToolkit::Declaration.new('margin', '0 10px 0 0')
		expected = "margin:0 10px 0 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_three
		declaration = CssToolkit::Declaration.new('margin', '0 0 10px 0')
		expected = "margin:0 0 10px 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_four
		declaration = CssToolkit::Declaration.new('margin', '0 0 0 10px')
		expected = "margin:0 0 0 10px"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

end
