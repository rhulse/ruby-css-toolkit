require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class YuiCompressorTest < Test::Unit::TestCase
  include CssToolkit

  def setup
    @yui = Yui.new()

		# build our tests based on the available files
		# test_files = Dir.glob(File.join(File.dirname(__FILE__), 'yuicss/*.css'))
		# test_files.each do |file|
		# 	base_name = File.basename(file, ".css")
		# 	class self <<
		# 		def test_yui_#{basename}
		# 			test_css 			= File.read(file)
		# 			expected_css 	= File.read(file + '.min')
		# 			assert_equal(expected_css, @yui.compress(test_css))
		# 		end
		#
		# end

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

	# test all the files in the yui directory
	def test_yui_css
		test_files = Dir.glob(File.join(File.dirname(__FILE__), 'yuicss/*.css'))
		test_files.each do |file|
	    test_css 			= File.read(file)
	    expected_css 	= File.read(file + '.min')

			test_name = File.basename(file, ".css")
			assert_block "Couldn't do the thing - #{test_name}" do
				expected_css == @yui.compress(test_css) #    do_the_thing
			end
#			assert_equal(), "'yui-#{test_name}' failed" )
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