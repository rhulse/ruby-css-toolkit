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

	def test_decimals
		declaration = CssToolkit::Declaration.new('margin', '0.6px 0.333pt 1.2em 8.8cm')
		expected = "margin:.6px .333pt 1.2em 8.8cm"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_rgb_colors
		declaration = CssToolkit::Declaration.new('color', 'rgb(123, 123, 123)')
		expected = "color:#7b7b7b"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_repeating_colors
		declaration = CssToolkit::Declaration.new('color', '#ffeedd')
		expected = "color:#fed"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_filter_untouched
		declaration = CssToolkit::Declaration.new('filter', 'chroma(color="#FFFFFF")')
		expected = 'filter:chroma(color="#FFFFFF")'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_rgb_in_background
		declaration = CssToolkit::Declaration.new('background', 'none repeat scroll 0 0 rgb(255, 0,0)')
		expected = 'background:none repeat scroll 0 0 #f00'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_rgba_is_untouched
		declaration = CssToolkit::Declaration.new('alpha', 'rgba(1, 2, 3, 4)')
		expected = 'alpha:rgba(1, 2, 3, 4)'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_1
		declaration = CssToolkit::Declaration.new('margin', '0px 0pt 0em 0%')
		expected = 'margin:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_2
		declaration = CssToolkit::Declaration.new('_padding-top', '0ex')
		expected = '_padding-top:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_3
		declaration = CssToolkit::Declaration.new('_padding-top', '0ex')
		expected = '_padding-top:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_4
		declaration = CssToolkit::Declaration.new('background-position', '0 0')
		expected = 'background-position:0 0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_5
		declaration = CssToolkit::Declaration.new('padding', '0in 0cm 0mm 0pc')
		expected = 'padding:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_downcase_property
		declaration = CssToolkit::Declaration.new('MaRGIn', '5px')
		declaration.downcase_property
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_modern_filters
		declaration = CssToolkit::Declaration.new('opacity', '0.8')
		declaration.optimize_filters
		expected = 'opacity:0.8'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_ie8_filters
		declaration = CssToolkit::Declaration.new('-ms-filter', 'progid:DXImageTransform.Microsoft.Alpha(Opacity=80)')
		declaration.optimize_filters
		expected = '-ms-filter:alpha(opacity=80)'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_ie4_to_7_filters
		declaration = CssToolkit::Declaration.new('filter', 'PROGID:DXImageTransform.Microsoft.Alpha(Opacity=80)')
		declaration.optimize_filters
		expected = 'filter:alpha(opacity=80)'
		assert_equal(expected, declaration.to_s)
	end

end
