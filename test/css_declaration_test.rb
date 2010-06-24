require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssDeclarationTest < Test::Unit::TestCase

	def test_declaration
		declaration = CssToolkit::Declaration.new('margin', '5px')
		expected = 'margin:5px'
		assert_equal(expected, declaration.to_s)
	end

end
