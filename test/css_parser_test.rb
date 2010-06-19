require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class TidyTest < Test::Unit::TestCase

	def setup
		@parser = CssTidy::Parser.new
	end

	def test_for_a_char
		@parser.css 	= "012W45"
		@parser.index		= 3
		assert @parser.is_char?('W')
	end

	def test_for_one_of_a_char
		@parser.css 	= "012x45"
		@parser.index		= 3
		assert @parser.is_char?(['W','x'])
	end

	def test_for_a_char_next
		@parser.css 	= "012W45"
		@parser.index		= 2
		assert @parser.is_char?('W', 1)
	end

	def test_for_one_of_a_char_next
		@parser.css 	= "012x45"
		@parser.index		= 2
		assert @parser.is_char?(['W','x'], 1)
	end


	# tests for tokens
	# %w[/ @ } { , : = ' " ( , \\ ! $ % & ) * + . < > ? [ ] ^ ` | ~]
	def test_is_token_at
		@parser.css 	= "012345@token"
		@parser.index		= 6
		assert @parser.is_token?
	end

	def test_is_token_left_curly
		@parser.css 	= "0123{token "
		@parser.index		= 4
		assert @parser.is_token?
	end

	def test_is_token_not
		@parser.css 	= "0123{token "
		@parser.index		= 8
		assert ! @parser.is_token?
	end

	def test_is_token_plus
		@parser.css 	= "0123{56+en "
		@parser.index		= 6
		assert ! @parser.is_token?
	end

	# tests for escaped characters
	def test_is_escaped
		@parser.css 	= '0123{5\\"6ken '
		@parser.index		= 7
		assert @parser.is_escaped?
	end

	def test_is_escaped_not
		@parser.css 	= '0123{5\\"6ken '
		@parser.index		= 4
		assert ! @parser.is_escaped?
	end

	# tests for comments
	def test_is_comment
		@parser.css 	= '01234/* comment */'
		@parser.index		= 5
		assert @parser.is_comment?
	end

	def test_is_comment_not
		@parser.css 	= '01234/* comment */'
		@parser.index		= 7
		assert ! @parser.is_comment?
	end

	def test_forward_slash_at_end_is_not_comment
		@parser.css 	= '01234/'
		@parser.index		= 5
		assert ! @parser.is_comment?
	end

	# test for new lines
	def test_is_newline
		@parser.css 	= "01234\n6789/"
		@parser.index		= 5
		assert @parser.is_newline?
	end

	def test_is_newline_carriage_return
		@parser.css 	= "01234\r6789/"
		@parser.index		= 5
		assert @parser.is_newline?
	end

	def test_is_newline_carriage_return_not
		@parser.css 	= "01234\r6789/"
		@parser.index		= 7
		assert ! @parser.is_newline?
	end

	# ctype tests - 'space'
	def test_is_ctype_space
		@parser.css 	= "01234 6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_t
		@parser.css 	= "01234\t6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_f
		@parser.css 	= "01234\f6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_v
		@parser.css 	= "01234\v6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_r
		@parser.css 	= "01234\r6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_not
		@parser.css 	= "1234\n6789/"
		@parser.index		= 8
		assert ! @parser.is_ctype?(:space)
	end

	# NB: Looping tests have one bad char at the start
	# to test that index inside function points to the
	# correct character

	# ctype tests - 'xdigit' (hexadecimal)
	def test_is_ctype_xdigit
		@parser.css 	= "z0123456789abcdefABCDEF"
		(1..22).each do |index|
			@parser.index	= index
			assert @parser.is_ctype?(:xdigit)
		end
	end

	# check the next char after the current index
	def test_is_next_char_ctype_xdigit
		@parser.css 	= "zzzzzzzzAzzzzzzzz"
		@parser.index	= 7
		assert @parser.is_ctype?(:xdigit, 1)
	end

	def test_is_ctype_xdigit_not
		@parser.css 	= "azxvprstlkhkw"
		(1..12).each do |index|
			@parser.index	= index
			assert ! @parser.is_ctype?(:xdigit)
		end
	end

	# ctype tests - alpha
	def test_is_ctype_alpha
		@parser.css 	= "0aBcDeFgHiJkLmNoPqRsTuVwXyZ"
		(1..26).each do |index|
			@parser.index	= index
			assert @parser.is_ctype?(:alpha)
		end
	end

	def test_is_ctype_alpha_not
		@parser.css 	= 'a0123456789$#{@!)(*&^%)}'
		(1..23).each do |index|
			@parser.index	= index
			assert ! @parser.is_ctype?(:alpha)
		end
	end

	def test_is_property_margin_next
		@parser.css 	= 'body{margin:5px;padding:10px;}'
		@parser.index	= 4
		assert @parser.property_is_next?
	end

	def test_is_property_padding_next
		@parser.css 	= 'body{margin:5px;padding:10px;}'
		@parser.index	= 15
		assert @parser.property_is_next?
	end

	def test_is_property_margin_next_with_spaces
		@parser.css 	= 'body{ margin  : 5px; padding:10px;}'
		@parser.index	= 4
		assert @parser.property_is_next?
	end

	def test_is_property_margin_next_not
		@parser.css 	= 'body{ margin  : 5px; padding:10px;}'
		@parser.index	= 2
		assert ! @parser.property_is_next?
	end

	#	if (code > 47 && code < 58) || (code > 64 && code < 91) || (code > 96 && code < 123)

	def test_convert_unicode_ascii
		(48..57).each do |code|
			@parser.css 	= "body{ \\#{code} argin  : 5px; padding:10px;}"
			@parser.index	= 6
			expected = code.chr
			assert_equal(expected, @parser.convert_unicode)
		end
		(65..90).each do |code|
			@parser.css 	= "body{ \\#{code} argin  : 5px; padding:10px;}"
			@parser.index	= 6
			expected = code.chr
			assert_equal(expected, @parser.convert_unicode)
		end
		(97..122).each do |code|
			@parser.css 	= "body{ \\#{code} argin  : 5px; padding:10px;}"
			@parser.index	= 6
			expected = code.chr
			assert_equal(expected, @parser.convert_unicode)
		end
	end

	def test_convert_unicode_non_ascii
		@parser.css 	= 'body{ \\margin  : 5px; padding:10px;}'
		@parser.index	= 6
		expected = '\\'
		assert_equal(expected, @parser.convert_unicode)
	end

	def test_parser
		css = <<-CSS
		body {
			margin:5px 10px 3px 1px
		}
		p     {
			padding: 2px 3px;
			font-size:12px;
		}
		CSS
		@parser.parse(css)

	end
	#   def setup
	#     @sc = CSS.new({:use_tidy => true})
	#   end
	#
	# # recheck that MS filters are not mangled by tidy color swapping
	#   def test_color_reduction
	#     css = <<-CSS
	#     .color {
	#       filter: chroma(color="#ffa500");
	#     }
	#     CSS
	#     expected = '.color{filter:chroma(color="#ffa500")}'
	#     assert_equal(expected, @sc.compress(css))
	#   end
	#
	# def test_color_swaps
	# 	css = <<-CSS
	# 	body {
	# 		color:#ff0000;
	# 		color:#f00;
	# 		color:#f00;
	# 		color:white;
	# 		color:black;
	#       color:fuchsia;
	#       color:yellow;
	#       color:#f00;
	# 		color:#800000;
	# 		color:#ffa500;
	# 		color:#808000;
	# 		color:#800080;
	# 		color:#008000;
	# 		color:#000080;
	# 		color:#008080;
	# 		color:#c0c0c0;
	# 		color:#808080;
	# 	}
	# 	CSS
	#     expected = 'body{color:red;color:red;color:red;color:#fff;color:#000;color:#f0f;color:#ff0;color:red;color:maroon;color:orange;color:olive;color:purple;color:green;color:navy;color:teal;color:silver;color:gray}'
	#     assert_equal(expected, @sc.compress(css))
	# end
	#
	# def test_clean_single_quoted_url
	# 	css = <<-CSS
	# 	body {
	# 		background: url('http://www.test.com/testing')
	# 	}
	# 	CSS
	#     expected = 'body{background:url(http://www.test.com/testing)}'
	#     assert_equal(expected, @sc.compress(css))
	# end
	#
	# def test_clean_double_quoted_url
	# 	css = <<-CSS
	# 	body {
	# 		background: url("http://www.test.com/testing")
	# 	}
	# 	CSS
	#     expected = 'body{background:url(http://www.test.com/testing)}'
	#     assert_equal(expected, @sc.compress(css))
	# end
	#
	# def test_clean_double_quoted_url_with_escape
	# 	css = <<-CSS
	# 	body {
	# 		background: url("http://www.test.com/te\\"sting")
	# 	}
	# 	CSS
	#     expected = 'body{background:url(http://www.test.com/te\"sting)}'
	#     assert_equal(expected, @sc.compress(css))
	# end

end