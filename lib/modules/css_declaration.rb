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
				CssTidy::SHORTEN_COLORS.each do |from,to|
					@value.gsub!(/#{from}/i, to)
				end
			end
		end

		def fix_invalid_colors
			if @value !~ /["'=]/
				CssTidy::INVALID_COLORS.each do |from,to|
					@value.gsub!(/#{from}/i, to)
				end
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

		def optimize_font_weight
			if @property =~ /font/
				@value.gsub!(/bold/, '700')
				@value.gsub!(/normal/, '400')
			end
		end

		def optimize_mp_shorthands
			if @property == 'margin' || @property == 'padding'
				values = @value.split(/\s+/)
				values
				case values.length
				when 4
						# 4 to 1   margin:5px 5px 5px 5px => margin:5px
					if values[0] == values[1] && values[0] == values[2] && values[0] == values[3]
						@value = "#{values[0]}"
						# 4 to 3     margin:0 0 10px 0 => margin:0 0 10px
					elsif values[0] == values[2] && values[1] == values[3]
						@value = "#{values[0]} #{values[1]}"
					#  4 to 2    margin:5px 0 5px 0 => margin:5px 0
					elsif values[1] == values[3]
						@value = "#{values[0]} #{values[1]} #{values[2]}"
					end
				when 3
						# 3 to 1   margin:5px 5px 5px => margin:5px
					if values[0] == values[1] && values[0] == values[2]
						@value = "#{values[0]}"
						# 3 to 2     margin:0 10px 0 => margin:0 10px
					elsif values[0] == values[2]
						@value = "#{values[0]} #{values[1]}"
					end
				when 2
						# 2 to 1   margin:5px 5px => margin:5px
					if values[0] == values[1]
						@value = "#{values[0]}"
					end
				end
			end
		end

		def optimize_urls
			# remove the quotes - they are optional
			@value.gsub!(/url\(('|")(.+?)('|")\)/, 'url(\2)')
		end

		def downcase_property
			@property.downcase!
		end

		def == (other)
			@property == other.property && @value == other.value
		end
	end
end

