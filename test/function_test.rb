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

	def test_charset_and_media_type
	  css = <<-CSS
	  @charset 'utf-8';
	  @media all {
	  body {
	  }
	  body {
	  background-color: gold;
	  }
	  }
	  CSS
	  expected = <<-CSS
@charset 'utf-8';
@media all
{
body
{background-color:gold}
}
CSS
		compressed = @sc.compress(css)
	  assert_equal(expected.rstrip, @sc.split_lines(compressed))
	end

	# check that lines are split when there are preserved tokens
	def test_at_attributes_and_preserved_strings
    sc = CSS.new({:tidy_test => true})
    css = <<-CSS
		/* te " st */
		a{a:1}
		/*!"preserve" me*/
		b{content: "/**/"}
		/* quite " quote ' \\' \\" */
		/* ie mac \\*/
		c {c : 3}
		/* end hiding */
		CSS
    expected = <<-CSS
a
{a:1}
/*___YUICSSMIN_PRESERVED_TOKEN_1___*/
b
{content:"___YUICSSMIN_PRESERVED_TOKEN_0___"}
/*___YUICSSMIN_PRESERVED_TOKEN_2___*/
c
{c:3}
/*___YUICSSMIN_PRESERVED_TOKEN_3___*/
CSS
		compressed = sc.compress(css)
	  assert_equal(expected.rstrip, sc.split_lines(compressed))
	end

end