require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class TidyTest < Test::Unit::TestCase

	def setup
		@parser = CssTidy::Parser.new
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
		@parser.css 	= "1234\n6789/"
		@parser.index		= 5
		assert @parser.is_newline?
	end

	def test_is_newline_carriage_return
		@parser.css 	= "1234\r6789/"
		@parser.index		= 5
		assert @parser.is_newline?
	end

	def test_is_newline_carriage_return_not
		@parser.css 	= "1234\r6789/"
		@parser.index		= 7
		assert ! @parser.is_newline?
	end

	# ctype tests - 'space'
	def test_is_ctype_space
		@parser.css 	= "1234 6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_t
		@parser.css 	= "1234\t6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_f
		@parser.css 	= "1234\f6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_v
		@parser.css 	= "1234\v6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_slash_r
		@parser.css 	= "1234\r6789/"
		@parser.index		= 5
		assert @parser.is_ctype?(:space)
	end

	def test_is_ctype_space_not
		@parser.css 	= "1234\n6789/"
		@parser.index		= 8
		assert ! @parser.is_ctype?(:space)
	end

	# ctype tests - 'xdigit' (hexadecimal)
	def test_is_ctype_xdigit
		@parser.css 	= "0123456789abcdefABCDEF"
		(0..21).each do |index|
			@parser.index	= index
			assert @parser.is_ctype?(:xdigit)
		end
	end

	def test_is_ctype_xdigit_not
		@parser.css 	= "zxvprstlkhkw"
		(0..11).each do |index|
			@parser.index	= index
			assert ! @parser.is_ctype?(:xdigit)
		end
	end

	# ctype tests - alpha
	def test_is_ctype_alpha
		@parser.css 	= "aBcDeFgHiJkLmNoPqRsTuVwXyZ"
		(0..25).each do |index|
			@parser.index	= index
			assert @parser.is_ctype?(:alpha)
		end
	end

	def test_is_ctype_alpha_not
		@parser.css 	= '0123456789$#{@!)(*&^%)}'
		(0..22).each do |index|
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