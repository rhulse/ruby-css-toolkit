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
    expected =  'p :link{margin:5px;foo:bar}'
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
    result = 'p:first-letter {font-weight:bold}p:first-line {line-height:1.5}p:first-line ,a,p:first-letter ,b{color:red}'
    assert_equal(result, @sc.compress(css))
  end

  def test_charset_reduction
    # this is not valid CSS but can occur when mulitple files are concatenated
    css = <<-CSS
    @charset "utf-8";
    #foo {
    	border-width:1px;
    }
    @charset "another one";
    #bar {
    	border-width:10px;
    }
    CSS
    expected = %Q!@charset "utf-8";#foo{border-width:1px}#bar{border-width:10px}!
    assert_equal(expected, @sc.compress(css))
  end

  def test_cleanup_zeros_and_measures
    css = <<-CSS
    a {
      margin: 0px 0pt 0em 0%;
      _padding-top: 0ex;
      background-position: 0 0;
      padding: 0in 0cm 0mm 0pc
    }
    CSS
    expected = 'a{margin:0;_padding-top:0;background-position:0 0;padding:0}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_leading_zero_removal
    css = <<-CSS
    ::selection {
      margin: 0.6px 0.333pt 1.2em 8.8cm;
    }
    CSS
    expected = '::selection{margin:.6px .333pt 1.2em 8.8cm}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_background_position_zero_removal
    css = <<-CSS
    a {background-position: 0 0 0 0;}
    b {BACKGROUND-POSITION: 0 0;}
    CSS
    expected = 'a{background-position:0 0}b{background-position:0 0}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_color_reduction
    css = <<-CSS
    .color {
      me: rgb(123, 123, 123);
      impressed: #ffeedd;
      filter: chroma(color="#FFFFFF");
      background: none repeat scroll 0 0 rgb(255, 0,0);
      alpha: rgba(1, 2, 3, 4);
    }
    CSS
    expected = '.color{me:#7b7b7b;impressed:#fed;filter:chroma(color="#FFFFFF");background:none repeat scroll 0 0 #f00;alpha:rgba(1,2,3,4)}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_opacity_reduction
    css = <<-CSS
    /*  example from https://developer.mozilla.org/en/CSS/opacity */
    pre {                               /* make the box translucent (80% opaque) */
       border: solid red;
       opacity: 0.8;                    /* Firefox, Safari(WebKit), Opera */
       -ms-filter: "progid:DXImageTransform.Microsoft.Alpha(Opacity=80)"; /* IE 8 */
       filter: PROGID:DXImageTransform.Microsoft.Alpha(Opacity=80);       /* IE 4-7 */
       zoom: 1;       /* set "zoom", "width" or "height" to trigger "hasLayout" in IE 7 and lower */
    }

    /** and again */
    code {
       -ms-filter: "PROGID:DXImageTransform.Microsoft.Alpha(Opacity=80)"; /* IE 8 */
       filter: progid:DXImageTransform.Microsoft.Alpha(Opacity=80);       /* IE 4-7 */
    }
    CSS
    expected = 'pre{border:solid red;opacity:.8;-ms-filter:"alpha(opacity=80)";filter:alpha(opacity=80);zoom:1}code{-ms-filter:"alpha(opacity=80)";filter:alpha(opacity=80)}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_box_model_hack
    css = <<-CSS
    #elem {
     width: 100px;
     voice-family: "\"}\"";
     voice-family:inherit;
     width: 200px;
    }
    html>body #elem {
     width: 200px;
    }
    CSS
    expected = %Q!#elem{width:100px;voice-family:"\"}\"";voice-family:inherit;width:200px}html>body #elem{width:200px}!
    assert_equal(expected, @sc.compress(css))
  end

  def test_font_face
    css = <<-CSS
    @font-face {
      font-family: 'gzipper';
      src: url(yanone.eot);
      src: local('gzipper'),
              url(yanone.ttf) format('truetype');
    }
    CSS
    expected = %Q!@font-face{font-family:'gzipper';src:url(yanone.eot);src:local('gzipper'),url(yanone.ttf) format('truetype')}!
    assert_equal(expected, @sc.compress(css))
  end
end