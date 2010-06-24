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

end
