require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssImportTest < Test::Unit::TestCase

	def test_import
		import = CssToolkit::Import.new('"import.css"')

		expected = '@import "import.css";'
		assert_equal(expected, import.to_s)
	end
end