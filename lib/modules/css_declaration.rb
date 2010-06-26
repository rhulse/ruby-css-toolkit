module CssToolkit

	class Declaration
		attr_accessor :property, :value

		# sets the values
		# we assume that any extraneous whitespace has been striped
		def initialize(property, value)
			@property = property
			@value = value
			self
		end

		def to_s(format=:one_line)
			unless @property.empty? &&  @value.empty?
				"#{@property}:#{@value}"
			end
		end

		def optimize_colors
      # Shorten colors from rgb(51,102,153) to #336699
      # This makes it more likely that it'll get further compressed in the next step.
      @value.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |match|
        '#' << $1.scan(/\d+/).map{|n| n.to_i.to_s(16).rjust(2, '0') }.join
      end

      # Shorten colors from #AABBCC to #ABC. Note that we want to make sure
      # the color is not preceded by either ", " or =. Indeed, the property
      #     filter: chroma(color="#FFFFFF");
      # would become
      #     filter: chroma(color="#FFF");
      # which makes the filter break in IE.
			if @value !~ /["'=]/
				@value.gsub!(/#([0-9a-f])\1([0-9a-f])\2([0-9a-f])\3/i, '#\1\2\3')
			end
		end

		def optimize_zeros
      # Replace 0(%, em, ex, px, in, cm, mm, pt, pc) with just 0.
      @value.gsub!(/(\s|\A)([+-]?0)(?:%|em|ex|px|in|cm|mm|pt|pc)/i, '\1\2')

			if @property =~ /background(-position)?/i
				@value.gsub!(/(0 )+0/, '0 0')
			else
	      # Replace 0 0 0 0; with 0.
	      @value.gsub!(/\A(?:0 )+0\Z/, '0')
			end
			# Replace 0.6 with .6, but only when it is the first rule or preceded by a space.
      @value.gsub!(/(\s|\A)0+\.(\d+)/, '\1.\2')
		end

		def optimize_filters
      # shorter opacity IE filter
      @value.gsub!(/progid:DXImageTransform\.Microsoft\.Alpha\(Opacity=/i, "alpha(opacity=")
		end
		
		def optimize_punctuation
      @value.gsub!(/\s+([!+\(\)\],])/, '\1')
      @value.gsub!(/([!+\(\[,])\s+/, '\1')
		end

		def downcase_property
			@property.downcase!
		end
	end
end

