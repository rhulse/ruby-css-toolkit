require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssCommentTest < Test::Unit::TestCase

	def test_comment
		comment = CssToolkit::Comment.new

		comment << ' A big comment '
		expected = '/* A big comment */'
		assert_equal(expected, comment.to_s)

		comment.text << ' - more text '
		expected = '/* A big comment  - more text */'
		assert_equal(expected, comment.to_s)

	end

	def test_special_comment
		comment = CssToolkit::Comment.new
		comment << '! A special comment '
		assert comment.is_special?
	end

	def test_not_a_special_comment
		comment = CssToolkit::Comment.new
		comment << ' A plain comment '
		assert ! comment.is_special?
	end

	def test_for_an_ie5_hack
		comment = CssToolkit::Comment.new
		comment << ' A hack comment \\'
		assert comment.is_ie5_hack?
	end

	def test_for_not_an_ie5_hack
		comment = CssToolkit::Comment.new
		comment << ' A plain comment '
		assert ! comment.is_ie5_hack?
	end

	def test_print_supression
		comment = CssToolkit::Comment.new
		comment << ' A plain comment '
		comment.printable = false
		assert_equal('', comment.to_s)
	end

	def test_clear
		comment = CssToolkit::Comment.new

		comment << ' A big comment '
		expected = '/* A big comment */'
		assert_equal(expected, comment.to_s)

		comment.clear 
		expected = ''
		assert_equal(expected, comment.to_s)

	end

end
