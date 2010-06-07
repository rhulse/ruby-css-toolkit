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

  def test_whitespace_and_unix_newline
    assert_equal('a b', @sc.compress(" a\n b"))
  end

  def test_whitespace_and_windows_newline
    assert_equal('a b', @sc.compress("   a  \r\nb "))
  end


end