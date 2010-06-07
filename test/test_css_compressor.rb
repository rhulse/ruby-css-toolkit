require File.dirname(__FILE__) + '/test_helper'

# Test cases for preping a file for parsing
class TestCssCompressor < Test::Unit::TestCase
  include CssCompressor

  def setup
    @sc = CSS.new
  end

  # basic test
  def test_pass_through
    assert_equal('body{margin:5px}', @sc.compress('body{margin:5px}'))
  end

  def test_whitespace_reduction
    assert_equal('a b', @sc.compress('  a   b  '))
  end

  def test_whitespace_reduction_with_tab
    assert_equal('a b', @sc.compress("  a  \t  b  "))
  end

  def test_whitespace_and_unix_newline
    assert_equal('a b', @sc.compress(" a\n b"))
  end

  def test_whitespace_and_windows_newline
    assert_equal('a b', @sc.compress("   a  \r\nb "))
  end

  def test_pseudo_class_retention
    css = <<-CSS
    p :link {
      margin:5px;
      foo:bar;
    }
    CSS
    expected =  'p :link{margin:5px;foo:bar;}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_ie_pseudo_first
    css = <<-CSS
    p:first-letter{
      font-weight: bold;
    }
    p:first-line{
      line-height: 1.5;
    }

    p:first-line,a,p:first-letter,b{
      color: red;
    }
    CSS
    result = 'p:first-letter {font-weight:bold;}p:first-line {line-height:1.5;}p:first-line ,a,p:first-letter ,b{color:red;}'
    assert_equal(result, @sc.compress(css))
  end

end