require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class CssTidyTest < Test::Unit::TestCase

	def setup
		@tidy = CssTidy::Tidy.new()
	end

	def test_basic
		css = <<-CSS
		body {
			background: #D6BFDC url('http://this.is-a.test/path/to/image.gif') repeat-x;
			padding: 0;
			margin: 0;
			color: #727272;
		}

		p {
			margin:0;
			hack: "\\"}";
			margin:10px ;
		}
		CSS
		expected_css = %q[body{background:#D6BFDC url('http://this.is-a.test/path/to/image.gif') repeat-x;padding:0;margin:0;color:#727272}p{margin:0;hack:"\\"}";margin:10px}]
		resultant_css = @tidy.tidy(css)
		assert_equal(expected_css, resultant_css)
	end

	# build our YUI tests based on the available files
	# the tests are run as per normal
	test_files = Dir.glob(File.join(File.dirname(__FILE__), 'yuicss/*.css'))
	test_files.each do |file|
	  test_css 			= File.read(file)
	  expected_css 	= File.read(file + '.min')
		test_name = File.basename(file, ".css")
		define_method("test_yui_css_#{test_name}") do
			test_name = File.basename(file, ".css")
			assert_equal(expected_css, @tidy.tidy(test_css), "YUI test #{test_name} failed")
		end
	end
end
