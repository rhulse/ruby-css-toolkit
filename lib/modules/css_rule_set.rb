module CssToolkit

	# The RuleSet class takes ONE selector and a set of declarations
	# Declarations are stored in order to allow for hacks such as the box model hacks
	class RuleSet
		def initialize(opts={})
      @selectors = []

			# declarations are made up of:  property S* ':' S* value;
      @properties = []
      @values = []
			add(opts)
		end

		def add(opts={})
			if opts[:selector] && opts[:declaration]
				# only add rules if the declaration is (probably) valid
				if opts[:declaration] =~ /:/
					@selectors << opts[:selector]
					declaration = opts[:declaration].gsub(';', '')
					property, value = opts[:declaration].split(':')
					@properties << property
					@values << value
				end
			end
		end

		def to_hash
			declarations = []
			@properties.each_index do |index|
				declarations << @properties[index] + ':' + @values[index]
			end
			{@selectors, declarations}
		end

	end

end