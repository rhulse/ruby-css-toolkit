require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class TidyTest < Test::Unit::TestCase
  include CssCompressor

  def setup
    @sc = CSS.new
  end

	# recheck that MS filters are not mangled by tidy color swapping
  def test_color_reduction
    css = <<-CSS
    .color {
      filter: chroma(color="#ffa500");
    }
    CSS
    expected = '.color{filter:chroma(color="#ffa500")}'
    assert_equal(expected, @sc.compress(css))
  end

	def test_color_swaps
		css = <<-CSS
		body {
			color: #ff0000;		
		}
		CSS
    expected = 'body{color:red}'
    assert_equal(expected, @sc.compress(css))
	end
end