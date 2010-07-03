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
		expected_css = %q[body{background:#D6BFDC url(http://this.is-a.test/path/to/image.gif) repeat-x;padding:0;margin:0;color:#727272}p{margin:0;hack:"\\"}";margin:10px}]
		resultant_css = @tidy.tidy(css)
		assert_equal(expected_css, resultant_css)
	end

	def test_escaping_property_hack
		css = <<-CSS
		/* \\*/
		* html #hright {overflow: hidden; ov\\erflow: visible;width: 100%;w\\idth: auto;he\\ight: 1%;}
		/* the above is for fixing italics bug */
		CSS
		expected_css = '/*\\*/* html #hright{overflow:hidden;ov\\erflow:visible;width:100%;w\\idth:auto;he\\ight:1%}/**/'
		resultant_css = @tidy.tidy(css)
		assert_equal(expected_css, resultant_css)
	end

	def test_escaping_property_hack
		css = 'body{ m\\argin  : 5px; padding:10px;}'
		expected_css = 'body{m\\argin:5px;padding:10px}'
		resultant_css = @tidy.tidy(css)
		assert_equal(expected_css, resultant_css)
	end

	# recheck that MS filters are not mangled by tidy color swapping
  def test_color_reduction
    css = <<-CSS
    .color {
      filter: chroma(color="#ffa500");
    }
    CSS
    expected = '.color{filter:chroma(color="#ffa500")}'
    assert_equal(expected, @tidy.tidy(css))
  end

	def test_color_swaps
		css = <<-CSS
		body {
			color:#ff0000;
			color:#f00;
			color:#f00;
			color:white;
			color:black;
	      color:fuchsia;
	      color:yellow;
	      color:#f00;
			color:#800000;
			color:#ffa500;
			color:#808000;
			color:#800080;
			color:#008000;
			color:#000080;
			color:#008080;
			color:#c0c0c0;
			color:#808080;
		}
		CSS
	    expected = 'body{color:red;color:red;color:red;color:#fff;color:#000;color:#f0f;color:#ff0;color:red;color:maroon;color:orange;color:olive;color:purple;color:green;color:navy;color:teal;color:silver;color:gray}'
	    assert_equal(expected, @tidy.tidy(css))
	end

	def test_clean_single_quoted_url
		css = <<-CSS
		body {
			background: url('http://www.test.com/testing')
		}
		CSS
	    expected = 'body{background:url(http://www.test.com/testing)}'
	    assert_equal(expected, @tidy.tidy(css))
	end

	def test_clean_double_quoted_url
		css = <<-CSS
		body {
			background: url("http://www.test.com/testing")
		}
		CSS
	    expected = 'body{background:url(http://www.test.com/testing)}'
	    assert_equal(expected, @tidy.tidy(css))
	end

	def test_clean_double_quoted_url_with_escape
		css = <<-CSS
		body {
			background: url("http://www.test.com/te\\"sting")
		}
		CSS
	    expected = 'body{background:url(http://www.test.com/te\"sting)}'
	    assert_equal(expected, @tidy.tidy(css))
	end

	def test_important
		css = 'body{ margin  : 5px; padding:10px  !important;}'
		expected_css = 'body{margin:5px;padding:10px!important}'
		resultant_css = @tidy.tidy(css)
		assert_equal(expected_css, resultant_css)
	end

	def test_important_with_shorthand
		css = 'body{ margin  : 5px; padding:10px 0 10px 0 !important;}'
		expected_css = 'body{margin:5px;padding:10px 0!important}'
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

	def test_some_css
		test_css = <<-CSS
		*{font-size:100%;margin:0;padding:0;}
		img{border:none;}
		#cont-pri img, .arc #cont-sec img, embed{border:1px solid #000;}
		body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04;}
		#pw{position:relative;width:960px;text-align:left;}
		CSS
		expected_css = %Q(*{font-size:100%;margin:0;padding:0}img{border:none}#cont-pri img,.arc #cont-sec img,embed{border:1px solid #000}body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04}#pw{position:relative;width:960px;text-align:left})
		assert_equal(expected_css, @tidy.tidy(test_css))
	end

	def test_line_length_split_at_50
		test_css = <<-CSS
		*{font-size:100%;margin:0;padding:0;}
		img{border:none;}
		#cont-pri img, .arc #cont-sec img, embed{border:1px solid #000;}
		body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04;}
		#pw{position:relative;width:960px;text-align:left;}
		CSS
		expected_css = %Q(*{font-size:100%;margin:0;padding:0}img{border:none}\n#cont-pri img,.arc #cont-sec img,embed{border:1px solid #000}\nbody{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04}\n#pw{position:relative;width:960px;text-align:left})
		assert_equal(expected_css, @tidy.tidy(test_css,{:line_length =>50}))
	end

	def test_line_length_split_at_100
		test_css = <<-CSS
		*{font-size:100%;margin:0;padding:0;}
		img{border:none;}
		#cont-pri img, .arc #cont-sec img, embed{border:1px solid #000;}
		body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04;}
		#pw{position:relative;width:960px;text-align:left;}
		CSS
		expected_css = %Q(*{font-size:100%;margin:0;padding:0}img{border:none}#cont-pri img,.arc #cont-sec img,embed{border:1px solid #000}\nbody{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04}#pw{position:relative;width:960px;text-align:left})
		assert_equal(expected_css, @tidy.tidy(test_css,{:line_length =>100}))
	end

	def test_line_length_split_at_300
		test_css = <<-CSS
		*{font-size:100%;margin:0;padding:0;}
		img{border:none;}
		#cont-pri img, .arc #cont-sec img, embed{border:1px solid #000;}
		body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04;}
		#pw{position:relative;width:960px;text-align:left;}
		CSS
		expected_css = %Q(*{font-size:100%;margin:0;padding:0}img{border:none}#cont-pri img,.arc #cont-sec img,embed{border:1px solid #000}body{background:#F5F1DA;font:small Verdana,Helvetica,Arial,sans-serif;color:#310C04}#pw{position:relative;width:960px;text-align:left})
		assert_equal(expected_css, @tidy.tidy(test_css,{:line_length =>300}))
	end
end
