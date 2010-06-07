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
    assert_equal(' ', @sc.compress(' '))
  end

  def test_whitespace_and_unix_newline
    assert_equal(' ', @sc.compress(" \n"))
  end

  def test_whitespace_and_windows_newline
    assert_equal(' ', @sc.compress(" \r\n"))
  end


end