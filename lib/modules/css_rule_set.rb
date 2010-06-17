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

		private

		def each_declaration
			@values.each_index do |index|
				yield @properties[index], @values[index]
			end
		end
	end
end