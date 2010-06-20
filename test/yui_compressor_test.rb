require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class YuiCompressorTest < Test::Unit::TestCase
  include CssToolkit

  def setup
    @yui = Yui.new()
  end

  # basic test
  def test_pass_through
    assert_equal('body{margin:5px}', @yui.compress('body{margin:5px}'))
  end

  def test_whitespace_reduction
    assert_equal('a b', @yui.compress('  a   b  '))
  end

  def test_whitespace_reduction_with_tab
    assert_equal('a b', @yui.compress("  a  \t  b  "))
  end

  def test_whitespace_and_unix_newline
    assert_equal('a b', @yui.compress(" a\n b"))
  end

  def test_whitespace_and_windows_newline
    assert_equal('a b', @yui.compress("   a  \r\nb "))
  end

	# build our YUI tests based on the available files
	# the tests are run as per normal
	test_files = Dir.glob(File.join(File.dirname(__FILE__), 'yuicss/*.css'))
	test_files.each_with_index do |file, idx|
  	test_css 			= File.read(file)
  	expected_css 	= File.read(file + '.min')
		test_name = File.basename(file, ".css")
		define_method("test_yui_css_#{test_name}") do
			test_name = File.basename(file, ".css")
			assert_block "YUI test #{test_name} failed" do
				expected_css == @yui.compress(test_css)
			end
		end
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
		assert_equal(expected_css, @yui.compress(test_css,50))
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
		assert_equal(expected_css, @yui.compress(test_css,100))
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
		assert_equal(expected_css, @yui.compress(test_css,300))
	end

end