require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssCharsetTest < Test::Unit::TestCase

	def test_charset
		charset = CssToolkit::Charset.new
		expected = '@charset "UTF-8";'
		assert_equal(expected, charset.to_s)

		charset << 'UTF-16'
		expected = '@charset "UTF-16";'
		assert_equal(expected, charset.to_s)

		charset.encoding = 'UTF-32'
		expected = '@charset "UTF-32";'
		assert_equal(expected, charset.to_s)
	end

end
