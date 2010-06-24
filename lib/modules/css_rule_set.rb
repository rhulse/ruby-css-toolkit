module CssToolkit

	# The RuleSet class takes ONE selector and a set of declarations
	# Declarations are stored in order to allow for hacks such as the box model hacks
	class RuleSet
		def initialize(opts={})
      @selectors = []

			# declarations are made up of:  property S* ':' S* value;
			@declarations = []
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
					@declarations << CssToolkit::Declaration.new(property.strip, value.strip)
				end
			end
		end

		def << (declaration)
			property, value = declaration.strip.split(':')
			@declarations << CssToolkit::Declaration.new(property.strip, value.strip)
		end

		def to_hash
			declarations = []
			@declarations.each do |declaration|
				declarations << declaration.to_s
			end
			{@selectors, declarations}
		end

		def to_s(format=:one_line)

			declarations = []
			@declarations.each do |declaration|
				declarations << declaration.to_s
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
		def optimize_colors
			@declarations.each do |declaration|
				declaration.optimize_colors
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