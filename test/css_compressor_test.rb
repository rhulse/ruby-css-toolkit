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

  def test_star_underscore_hacks
    css = <<-CSS
    #elementarr {
      width: 1px;
      *width: 3pt;
      _width: 2em;
    }
    CSS
    expected = '#elementarr{width:1px;*width:3pt;_width:2em}'
    assert_equal(expected, @sc.compress(css))
  end

  def test_preserve_special_comments
    css = <<-CSS
/*!************88****
 Preserving comments
    as they are
 ********************
 Keep the initial !
 *******************/
#yo {
    ma: "ma";
}
/*!
I said
pre-
serve! */
CSS
    expected = <<-CSS
/*!************88****
 Preserving comments
    as they are
 ********************
 Keep the initial !
 *******************/#yo{ma:"ma"}/*!
I said
pre-
serve! */
CSS
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_ie7_comment_hack
    css = <<-CSS
    html >/**/ body p {
        color: blue;
    }
    CSS
    expected = 'html>/**/body p{color:blue}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_charset_media
    css = <<-CSS
    /* re: 2495387 */
    @charset 'utf-8';
    @media all {
    body {
    }
    body {
    background-color: gold;
    }
    }
    CSS
    expected = "@charset 'utf-8';@media all{body{background-color:gold}}"
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_dollar_header
    css = <<-CSS
/*!
$Header: /temp/dirname/filename.css 3 2/02/08 3:37p JSmith $
*/

foo {
  bar: baz
}
CSS
    expected = <<-CSS
/*!
$Header: /temp/dirname/filename.css 3 2/02/08 3:37p JSmith $
*/foo{bar:baz}
CSS
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_empty_class
    css = <<-CSS
/*! preserved */
emptiness {}

@import "another.css";
/* I'm empty - delete me */
empty { ;}

@media print {
  .noprint { display: none; }
}

@media screen {
  /* this rule should be removed, not simply minified.*/
  .breakme {}
  .printonly { display: none; }
}
CSS
    expected = '/*! preserved */@import "another.css";@media print{.noprint{display:none}}@media screen{.printonly{display:none}}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_media_multi
    css = <<-CSS
    @media only all and (max-width:50em), only all and (max-device-width:800px), only all and (max-width:780px) {
      some-css : here
    }
    CSS
    expected = '@media only all and (max-width:50em),only all and (max-device-width:800px),only all and (max-width:780px){some-css:here}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_media
    css = <<-CSS
    @media screen and (-webkit-min-device-pixel-ratio:0) {
      some-css : here
    }
    CSS
    expected = '@media screen and (-webkit-min-device-pixel-ratio:0){some-css:here}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_opacity_filter
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
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_bug_2527974
    css = <<-CSS
    /*  this file contains no css, it exists purely to put the revision number into the
      combined css before uploading it to SiteManager. The exclaimation at the start
      of the comment informs yuicompressor not to strip the comment out */

    /*! $LastChangedRevision: 81 $ $LastChangedDate: 2009-05-27 17:41:02 +0100 (Wed, 27 May 2009) $ */

    body {
        yo: cats;
    }
    CSS
    expected = '/*! $LastChangedRevision: 81 $ $LastChangedDate: 2009-05-27 17:41:02 +0100 (Wed, 27 May 2009) $ */body{yo:cats}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_bug_2527991
    css = <<-CSS
    @media screen and/*!YUI-Compresser */(-webkit-min-device-pixel-ratio:0) {
      a{
        b: 1;
      }
    }


    @media screen and/*! */ /*! */(-webkit-min-device-pixel-ratio:0) {
      a{
        b: 1;
      }
    }


    @media -webkit-min-device-pixel-ratio:0 {
      a{
        b: 1;
      }
    }
    CSS
    expected = '@media screen and/*!YUI-Compresser */(-webkit-min-device-pixel-ratio:0){a{b:1}}@media screen and/*! *//*! */(-webkit-min-device-pixel-ratio:0){a{b:1}}@media -webkit-min-device-pixel-ratio:0{a{b:1}}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_bug_2527998
    css = <<-CSS
    /*! special */
    body {

    }
    CSS
    expected = '/*! special */'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_bug_2528034
    css = <<-CSS
    a[href$="/test/"] span:first-child { b:1; }
    a[href$="/test/"] span:first-child { }

    CSS
    expected = 'a[href$="/test/"] span:first-child{b:1}'
    assert_equal(expected.strip, @sc.compress(css))
  end

  # In the following tests the \ in the CSS is escaped
  # Where there is a \\ this is = to one \ in the CSS

  def test_ie5_mac_hack
    css = <<-CSS
    /* Ignore the next rule in IE mac \\*/
    .selector {
       color: khaki;
    }
    /* Stop ignoring in IE mac */
    CSS
    expected = '/*\*/.selector{color:khaki}/**/'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_string_in_comment
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
    expected = 'a{a:1}/*!"preserve" me*/b{content:"/**/"}/*\*/c{c:3}/**/'
    assert_equal(expected.strip, @sc.compress(css))
  end

  def test_preserve_new_line
    css = <<-CSS
#sel-o {
  content: "on\\"ce upon \
a time";
CSS
 css += <<CSS
  content: 'once upon \
a ti\'me';
}
CSS
    expected = <<-CSS
#sel-o{content:"on\\"ce upon \
a time";content:'once upon \
a ti\'me'}
CSS
    assert_equal(expected.rstrip, @sc.compress(css))
  end

  def test_string_in_comment
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
    expected = 'a{a:1}/*!"preserve" me*/b{content:"/**/"}/*\*/c{c:3}/**/'
    assert_equal(expected.rstrip, @sc.compress(css))
  end

  def test_preserve_strings
		# read this ones in from files because of all the escaping used
    css = File.read(File.join(File.dirname(__FILE__), 'css/preserve_string.css'))
    expected = File.read(File.join(File.dirname(__FILE__), 'css/preserve_string.css.min'))
    assert_equal(expected, @sc.compress(css))
  end

end