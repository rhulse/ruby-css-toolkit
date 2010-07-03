$:.unshift File.dirname(__FILE__)
require 'css_properties'

module CssTidy

	# The RuleSet class takes ONE selector and a set of declarations
	# Declarations are stored in order to allow for hacks such as the box model hacks
	class RuleSet < CssBase
		attr_accessor :declarations, :selectors

		def initialize(opts={})
      @selectors = []

			# declarations are made up of:  property S* ':' S* value;
			@declarations = []
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
						@declarations << CssTidy::Declaration.new(property.strip, value.strip)
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
			@declarations << CssTidy::Declaration.new(property.strip, value.strip)
		end

		def to_hash
			declarations = []
			@declarations.each do |declaration|
				declarations << declaration.to_s
			end
			{@selectors, declarations}
		end

		def to_s(format=:one_line)
			return '' if @selectors.empty? || @declarations.empty?

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
			merge_4_part_longhands
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

		def merge_4_part_longhands
			SHORTHANDS.each do |shorthand, longhands|
				values = []
				important_count = 0
				@declarations.each_with_index do |declaration, idx|
					# if one is important, the new merged rule will be important.
					# this will probably break CSS in some rare cases
					important_count = declaration.important? ? important_count + 1 : important_count + 0
					case declaration.property
					when longhands[0]
						values[0] = declaration.value
					when longhands[1]
						values[1] = declaration.value
					when longhands[2]
						values[2] = declaration.value
					when longhands[3]
						values[3] = declaration.value
					end
				end
				# remove nil values
				values.compact!
				if values.size == 4
					# remove the old ones
					@declarations.delete_if do |decl|
						longhands.include?(decl.property)
					end
					values.map!{|v| v.gsub(/!important/, '').strip}
					important = important_count > 0 ? '!important' : ''
					# add the new rule
					@declarations << CssTidy::Declaration.new(shorthand, values.join(' ') + important)
				end
			end
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
			# must at least have the same number of declarations and be same type of object
			if other_set.respond_to?(:declaration_count) && declaration_count == other_set.declaration_count
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

		def + (other_set)
			@selectors += other_set.selectors
			self
		end

		def declaration_count
			@declarations.length
		end

		def inspect(indent='')
			puts indent + " + " + @selectors.join(',')
			 @declarations.each do |decl|
				puts indent * 2 + "| " + decl.to_s
			end
		end

		def clear
      @selectors = []
			@declarations = []
		end

		private


		def each_declaration
			@values.each_index do |index|
				yield @properties[index], @values[index]
			end
		end
	end
end