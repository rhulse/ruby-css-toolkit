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
    assert_equal(expected, @sc.compress(css))
	end

end