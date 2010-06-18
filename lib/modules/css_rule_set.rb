module CssToolkit

	# The RuleSet class takes ONE selector and a set of declarations
	# Declarations are stored in order to allow for hacks such as the box model hacks
	class RuleSet
		def initialize(opts={})
      @selectors = []

			# declarations are made up of:  property S* ':' S* value;
      @properties = []
      @values = []
			add_rule(opts)
		end

		def add_rule(opts={})
			if opts[:selector] && opts[:declarations]
			# we assume the declarations are valid, but some cleanup of whitespace is done
				@selectors << opts[:selector].strip
				opts[:declarations].strip.split(';').each do |declaration|
					property, value = declaration.strip.split(':')
					@properties << property.strip
					@values << value.strip.gsub(/\s+/, ' ')
				end
			end
		end

		def << (declaration)
			property, value = declaration.strip.split(':')
			@properties << property.strip
			@values << value.strip.gsub(/\s+/, ' ')
		end

		def to_hash
			declarations = []
			@properties.each_index do |index|
				declarations << @properties[index] + ':' + @values[index]
			end
			{@selectors, declarations}
		end

		def to_s(format=:one_line)

			declarations = []
			each_declaration do |property, value|
				declarations << "#{property}:#{value}"
			end

			case format
			when :one_line
				@selectors.join(',') + '{' + declarations.join(';') + '}'
			when :multi_line
				@selectors.join(',') + "{\n  " + declarations.join(";\n  ") + "\n}"
			end
		end

		# Rule Sets know how to optimise themselves

		# starting with colors
		def optimise_colors
			@values.map! do |value|
	      # Shorten colors from rgb(51,102,153) to #336699
	      # This makes it more likely that it'll get further compressed in the next step.
	      value.gsub!(/rgb\s*\(\s*([0-9,\s]+)\s*\)/) do |match|
	        '#' << $1.scan(/\d+/).map{|n| n.to_i.to_s(16).rjust(2, '0') }.join
	      end

	      # Shorten colors from #AABBCC to #ABC. Note that we want to make sure
	      # the color is not preceded by either ", " or =. Indeed, the property
	      #     filter: chroma(color="#FFFFFF");
	      # would become
	      #     filter: chroma(color="#FFF");
	      # which makes the filter break in IE.
				if value !~ /["'=]/
					value.gsub!(/#([0-9a-f])\1([0-9a-f])\2([0-9a-f])\3/i, '#\1\2\3')
				end

				value
			end
		end

		private

		def each_declaration
			@values.each_index do |index|
				yield @properties[index], @values[index]
			end
		end
	end
end