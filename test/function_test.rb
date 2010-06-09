require File.dirname(__FILE__) + '/test_helper'

# Test cases for individual functions in tidy

class FunctionTest < Test::Unit::TestCase
  include CssCompressor

  def setup
    @sc = CSS.new
  end

	def test_line_spliter_with_import_and_media
		css = <<-CSS
		@import "subs.css";
		@media print {
		  @import "print-main.css";
		  body { font-size: 10pt }
		}
		h1 {color: blue }
		CSS
		expected = <<-CSS
@import "subs.css";
@media print
{
@import "print-main.css";
body
{font-size:10pt}
}
h1
{color:blue}
CSS
		compressed = @sc.compress(css)
    assert_equal(expected.rstrip, @sc.split_lines(compressed))
	end

	def test_complex_media_groups
		css = <<-CSS
		h1 {
			margin:50px
		}
		@media (max-width: 600px) {
			h1 {
				margin:20px;
			}
		}
		@media (max-width: 400px) {
			h1 {
				margin:10px;
			}
		}
		@media (min-width: 1300px) {
			h1 {
				margin:15px
			}
		}
		CSS
		
		expected = <<-CSS
h1
{margin:50px}
@media(max-width:600px)
{
h1
{margin:20px}
}
@media(max-width:400px)
{
h1
{margin:10px}
}
@media(min-width:1300px)
{
h1
{margin:15px}
}
CSS
		compressed = @sc.compress(css)
		assert_equal(expected.rstrip, @sc.split_lines(compressed))
	end

end