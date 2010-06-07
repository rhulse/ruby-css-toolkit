# This is a Ruby port of the YUI CSS compressor
# See LICENSE for license information

module CssCompressor
  # Compress CSS rules using a variety of techniques

  class CSS
    def initialize
      @preservedTokens = []
      @comments = []
    end

    def compress(css)

      css = process_comments_and_strings(css)

      # Normalize all whitespace strings to single spaces. Easier to work with that way.
      css.gsub!(/\s+/, ' ');

      # Remove the spaces before the things that should not have spaces before them.
      # But, be careful not to turn "p :link {...}" into "p:link{...}"
      # Swap out any pseudo-class colons with the token, and then swap back.
      css.gsub!(/(?:^|\})[^\{:]+\s+:+[^\{]*\{/) do |match|
        match.gsub(':', '___PSEUDOCLASSCOLON___')
      end
      css.gsub!(/\s+([!\{\};:>+\(\)\],])/, '\1')
      css.gsub!(/([!\{\}:;>+\(\[,])\s+/, '\1')
      css.gsub!('___PSEUDOCLASSCOLON___', ':')

      # special case for IE
      css.gsub!(/:first-(line|letter)(\{|,)/, ':first-\1 \2');

      # If there is a @charset, then only allow one, and push to the top of the file.
      css.gsub!(/^(.*)(@charset "[^"]*";)/i, '\2\1');
      css.gsub!(/^(\s*@charset [^;]+;\s*)+/i, '\1');

      # Put the space back in some cases, to support stuff like
      # @media screen and (-webkit-min-device-pixel-ratio:0){
      css.gsub!(/\band\(/i, "and (")

      # remove unnecessary semicolons
      css.gsub!(/;+\}/, '}')

      # Replace 0(%, em, ex, px, in, cm, mm, pt, pc) with just 0.
      css.gsub!(/([\s:])([+-]?0)(?:%|em|ex|px|in|cm|mm|pt|pc)/i, '\1\2')

      # Replace 0 0 0 0; with 0.
      css.gsub!(/:(?:0 )+0(;|\})/, ':0\1')

      # Restore background-position:0 0; if required
      css.gsub!(/background-position:0(;|\})/i, 'background-position:0 0\1')

      # Replace 0.6 with .6, but only when preceded by : or a space.
      css.gsub!(/(:|\s)0+\.(\d+)/, '\1.\2')

      # Shorten colors from rgb(51,102,153) to #336699
      # This makes it more likely that it'll get further compressed in the next step.
      css.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |match|
        '#' << $1.scan(/\d+/).map{|n| n.to_i.to_s(16).rjust(2, '0') }.join
      end

      # Shorten colors from #AABBCC to #ABC. Note that we want to make sure
      # the color is not preceded by either ", " or =. Indeed, the property
      #     filter: chroma(color="#FFFFFF");
      # would become
      #     filter: chroma(color="#FFF");
      # which makes the filter break in IE.
      css.gsub!(/([^"'=\s])(\s?)\s*#([0-9a-f])\3([0-9a-f])\4([0-9a-f])\5/i, '\1\2#\3\4\5')

      # shorter opacity IE filter
      css.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=");


      # top and tail whitespace
      css.strip!

      css
    end

    def process_comments_and_strings(css_text)
      css = css_text.clone

      startIndex = 0
      endIndex = 0
      i = 0
      max = 0
      token = ''
      totallen = css.length
      placeholder = ''

      # collect all comment blocks
      while (startIndex = css.index(/\/\*/, startIndex))
        endIndex = css.index(/\*\//, startIndex + 2)
        unless endIndex
          endIndex = totallen
        end
        token = css.slice(startIndex+2..endIndex-1)
        puts token
        @comments.push(token)
        css = css.slice(0..startIndex+1).to_s + "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" + (@comments.length - 1).to_s + "___" + css.slice(endIndex, totallen).to_s
        startIndex += 2
      end

      @comments.each_index do |index|
        token = @comments[index]
        placeholder = "___YUICSSMIN_PRESERVE_CANDIDATE_COMMENT_" + index.to_s + "___"

        # in all other cases kill the comment
        css.gsub!( /\/\*#{placeholder}\*\//, "");
        
      end

      css
    end
  end

end