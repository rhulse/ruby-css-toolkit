# This is a Ruby port of the YUI CSS compressor
# See LICENSE for license information

module CssCompressor
  # Compress CSS rules using a variety of techniques

  class CSS
    def initialize

    end

    def compress(css)

      # Normalize all whitespace strings to single spaces. Easier to work with that way.
      css.gsub!(/\s+/, ' ');

      css
    end
  end

end