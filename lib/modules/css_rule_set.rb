module CssToolkit

	# The RuleSet class takes ONE selector and a set of declarations
	# Declarations are stored in order to allow for hacks such as the box model hacks
	class RuleSet
		attr_accessor :declarations

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

		def optimize(options)
			@declarations.each do |declaration|
				declaration.optimize_colors 			 	if options[:optimize_colors]
				declaration.fix_invalid_colors 			if options[:fix_invalid_colors]
				declaration.downcase_property 		 	if options[:downcase_properties]
				declaration.optimize_zeros				 	if options[:optimize_zeros]
				declaration.optimize_mp_shorthands 	if options[:optimize_margin_padding]
				declaration.optimize_filters			 	if options[:optimize_filters]
				declaration.optimize_urls						if options[:optimize_urls]
				declaration.optimize_font_weight		if options[:optimize_font_weight]
				declaration.optimize_punctuation  # no option
			end
			optimize_selectors(options)
		end

		def optimize_selectors(options)
			@selectors.map do |selector|
				# squish up IE comment in selector hack
				selector.gsub!(/\s*>\s*\/\*\s*\*\/\s*/, '>/**/' )
	      # special case for IE
	      selector.gsub!(/:first-(line|letter)(,|\Z)/, ':first-\1 \2')
				# remove any kind of comment string
				if options[:keep_ie7_selector_comments]
					selector.gsub!(/\/\*\*\//, '_IE7_') # protect from next options
				end
				if ! options[:keep_selector_comments]
					selector.gsub!(/(\s+)?\/\*(.|[\r\n])*?\*\/(\s+)?/, '')
				end
				selector.gsub!(/_IE7_/, '/**/') # restore hack comments

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

		def empty?
			@declarations.empty?
		end
		
		def == (other_set)
			# must at least have the same number of declarations
			if declaration_count == other_set.declaration_count
				number_of_identical_declations = 0
				other_set.declarations.each do |other_dec|
					@declarations.each do |this_dec|
						if this_dec == other_dec
							number_of_identical_declations += 1
						end
					end
				
				end
				true if declaration_count == number_of_identical_declations
			end
		end

		def declaration_count
			@declarations.length
		end

		private


		def each_declaration
			@values.each_index do |index|
				yield @properties[index], @values[index]
			end
		end
	end
end