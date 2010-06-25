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
			# we assume the declarations are valid, but top and tail whitespace
			# and avoid duplicate selectors
				@selectors << opts[:selector].strip unless @selectors.member?( opts[:selector])
	      opts[:declarations].strip.split(/[\;$]+/m).each do |declaration|
	        if matches = declaration.match(/(.[^:]*)\:(.[^;]*)(;|\Z)/i)
	          property, value, end_of_declaration = matches.captures
						@declarations << CssToolkit::Declaration.new(property.strip, value.strip)
	        end
	      end
				opts[:declarations].strip.split(';').each do |declaration|
					property, value = declaration.strip.split(/:/)
				end
			end
			self
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

		def optimize
			@declarations.each do |declaration|
				declaration.optimize_colors
				declaration.downcase_property
				declaration.optimize_zeros
			end
		end

		# starting with colors
		def optimize_colors
			@declarations.each do |declaration|
				declaration.optimize_colors
			end
		end

		# starting with colors
		def downcase_selectors
			@selectors.map {|selector| selector.downcase }
		end

		private

		def each_declaration
			@values.each_index do |index|
				yield @properties[index], @values[index]
			end
		end
	end
end