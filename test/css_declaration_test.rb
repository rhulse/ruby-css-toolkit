require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssDeclarationTest < Test::Unit::TestCase

	def test_declaration
		declaration = CssTidy::Declaration.new('margin', '5px')
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_one
		declaration = CssTidy::Declaration.new('margin', '10px 0 0 0')
		expected = "margin:10px 0 0 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_two
		declaration = CssTidy::Declaration.new('margin', '0 10px 0 0')
		expected = "margin:0 10px 0 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_three
		declaration = CssTidy::Declaration.new('margin', '0 0 10px 0')
		expected = "margin:0 0 10px 0"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_4_value_zero_reduction_place_four
		declaration = CssTidy::Declaration.new('margin', '0 0 0 10px')
		expected = "margin:0 0 0 10px"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_decimals
		declaration = CssTidy::Declaration.new('margin', '0.6px 0.333pt 1.2em 8.8cm')
		expected = "margin:.6px .333pt 1.2em 8.8cm"
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_rgb_colors
		declaration = CssTidy::Declaration.new('color', 'rgb(123, 123, 123)')
		expected = "color:#7b7b7b"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_repeating_colors
		declaration = CssTidy::Declaration.new('color', '#ffeedd')
		expected = "color:#fed"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_filter_untouched
		declaration = CssTidy::Declaration.new('filter', 'chroma(color="#FFFFFF")')
		expected = 'filter:chroma(color="#FFFFFF")'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_rgb_in_background
		declaration = CssTidy::Declaration.new('background', 'none repeat scroll 0 0 rgb(255, 255,0)')
		expected = 'background:none repeat scroll 0 0 #ff0'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_rgba_is_untouched
		declaration = CssTidy::Declaration.new('alpha', 'rgba(1, 2, 3, 4)')
		expected = 'alpha:rgba(1, 2, 3, 4)'
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_color_replacement_short
		declaration = CssTidy::Declaration.new('color', '#f00')
		expected = "color:red"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_color_replacement_long
		declaration = CssTidy::Declaration.new('color', '#ff0000')
		expected = "color:red"
		declaration.optimize_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_color_fix
		declaration = CssTidy::Declaration.new('color', 'brown')
		expected = "color:#A52A2A"
		declaration.fix_invalid_colors
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_1
		declaration = CssTidy::Declaration.new('margin', '0px 0pt 0em 0%')
		expected = 'margin:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_2
		declaration = CssTidy::Declaration.new('_padding-top', '0ex')
		expected = '_padding-top:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_3
		declaration = CssTidy::Declaration.new('_padding-top', '0ex')
		expected = '_padding-top:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_4
		declaration = CssTidy::Declaration.new('background-position', '0 0')
		expected = 'background-position:0 0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_zeros_5
		declaration = CssTidy::Declaration.new('padding', '0in 0cm 0mm 0pc')
		expected = 'padding:0'
		declaration.optimize_zeros
		assert_equal(expected, declaration.to_s)
	end

	def test_downcase_property
		declaration = CssTidy::Declaration.new('MaRGIn', '5px')
		declaration.downcase_property
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_modern_filters
		declaration = CssTidy::Declaration.new('opacity', '0.8')
		declaration.optimize_filters
		expected = 'opacity:0.8'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_ie8_filters
		declaration = CssTidy::Declaration.new('-ms-filter', 'progid:DXImageTransform.Microsoft.Alpha(Opacity=80)')
		declaration.optimize_filters
		expected = '-ms-filter:alpha(opacity=80)'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_ie4_to_7_filters
		declaration = CssTidy::Declaration.new('filter', 'PROGID:DXImageTransform.Microsoft.Alpha(Opacity=80)')
		declaration.optimize_filters
		expected = 'filter:alpha(opacity=80)'
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_4_to_3
		declaration = CssTidy::Declaration.new('margin', '0 0 10px 0')
		expected = "margin:0 0 10px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_4_to_2
		declaration = CssTidy::Declaration.new('margin', '5px 2px 5px 2px')
		expected = "margin:5px 2px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_4_to_1
		declaration = CssTidy::Declaration.new('margin', '5px 5px 5px 5px')
		expected = "margin:5px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_3_to_2
		declaration = CssTidy::Declaration.new('margin', '5px 2px 5px')
		expected = "margin:5px 2px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_3_to_1
		declaration = CssTidy::Declaration.new('margin', '5px 5px 5px')
		expected = "margin:5px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_margin_shorthand_2_to_1
		declaration = CssTidy::Declaration.new('margin', '5px 5px')
		expected = "margin:5px"
		declaration.optimize_mp_shorthands
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_urls_double_quotes
		declaration = CssTidy::Declaration.new('background', 'url("www.test.com/path/to/image.jpg")')
		expected = "background:url(www.test.com/path/to/image.jpg)"
		declaration.optimize_urls
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_urls_single_quotes
		declaration = CssTidy::Declaration.new('background', "url('www.test.com/path/to/image.jpg')")
		expected = "background:url(www.test.com/path/to/image.jpg)"
		declaration.optimize_urls
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_font_weight_bold
		declaration = CssTidy::Declaration.new('font-weight', 'bold')
		expected = "font-weight:700"
		declaration.optimize_font_weight
		assert_equal(expected, declaration.to_s)
	end

	def test_optimize_font_weight_normal
		declaration = CssTidy::Declaration.new('font', '12px normal')
		expected = "font:12px 400"
		declaration.optimize_font_weight
		assert_equal(expected, declaration.to_s)
	end

	def test_equality
		dec_1 = CssTidy::Declaration.new('margin', '0 0 10px 0')
		dec_2 = CssTidy::Declaration.new('margin', '0 0 10px 0')
		assert dec_1 == dec_2
	end

	def test_inequality
		dec_1 = CssTidy::Declaration.new('margin', '0 0 10px 0')
		dec_2 = CssTidy::Declaration.new('margin', '0 5px 10px 0')
		assert dec_1 != dec_2
	end

	def test_important
		dec_1 = CssTidy::Declaration.new('margin', '0 0 10px 0 !important')
		assert dec_1.important?
	end

	def test_not_important
		dec_1 = CssTidy::Declaration.new('margin', '0 0 10px 0')
		assert ! dec_1.important?
	end

	def test_clear
		declaration = CssTidy::Declaration.new('margin', '5px')
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)

		declaration.clear
		assert_equal('', declaration.to_s)
	end

end
